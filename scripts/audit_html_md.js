#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const projectRoot = process.cwd();
let hadError = false;

function walk(dir) {
  const files = fs.readdirSync(dir, { withFileTypes: true });
  
  for (const file of files) {
    const fullPath = path.join(dir, file.name);
    const relativePath = path.relative(projectRoot, fullPath);
    
    // Skip hidden directories and files
    if (file.name.startsWith('.')) continue;
    
    if (file.isDirectory()) {
      walk(fullPath);
    } else if (file.name.endsWith('.html')) {
      const content = fs.readFileSync(fullPath, 'utf8');
      auditHTML(relativePath, content);
    } else if (file.name.endsWith('.md')) {
      const content = fs.readFileSync(fullPath, 'utf8');
      auditMarkdown(relativePath, content);
    }
  }
}

function auditHTML(filePath, html) {
  // Only check documents that have a DOCTYPE or <html> tag
  if (!html.includes('<!DOCTYPE') && !html.includes('<html')) {
    return; // Skip fragments
  }

  // Check for html lang attribute
  const htmlMatch = html.match(/<html[^>]*>/i);
  if (htmlMatch) {
    const htmlTag = htmlMatch[0];
    if (!/\slang\s*=/i.test(htmlTag)) {
      console.error(`[AUDIT][ERROR] ${filePath}: html_lang_required: <html> missing lang attribute`);
      hadError = true;
    }
  } else {
    return; // Skip non-document fragments
  }

  const titleMatch = html.match(/<title[^>]*>([^<]*)<\/title>/i);
  if (!titleMatch || !titleMatch[1].trim()) {
    console.error(`[AUDIT][ERROR] ${filePath}: title_present: <title> missing or empty`);
    hadError = true;
  }

  if (!/name\s*=\s*['"]\s*viewport\s*['"]/i.test(html)) {
    console.warn(`[AUDIT][WARN] ${filePath}: meta_viewport_present: Missing meta viewport`);
  }
}

function auditMarkdown(filePath, md) {
  const lines = md.split(/\r?\n/);
  let lastLevel = 0;
  for (const line of lines) {
    const m = line.match(/^(#{1,6})\s+\S/);
    if (!m) continue;
    const level = m[1].length;
    if (lastLevel > 0 && level > lastLevel + 1) {
      console.warn(`[AUDIT][WARN] ${filePath}: heading_increment: Heading level jumped from H${lastLevel} to H${level}`);
    }
    lastLevel = level;
  }
}

walk(projectRoot);
process.exit(hadError ? 1 : 0);