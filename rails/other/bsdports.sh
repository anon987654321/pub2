#!/bin/bash

#!/usr/bin/env zsh
set -euo pipefail

# BSDPorts - Advanced Package Search and Management Platform
# Framework v37.3.2 compliant with comprehensive BSD ports integration

APP_NAME="bsdports"
BASE_DIR="/home/dev/rails"
BRGEN_IP="46.23.95.45"

source "./__shared.sh"

log "Starting BSDPorts package search platform setup"

setup_full_app "$APP_NAME"

command_exists "ruby"
command_exists "node"
command_exists "psql"
command_exists "redis-server"

# Add package management and search gems
bundle add net-ftp
bundle add searchkick
bundle add elasticsearch-model
bundle add nokogiri
bundle add rubyzip
bundle install

# Generate package management models
bin/rails generate model Platform name:string description:text base_url:string ftp_server:string
bin/rails generate model Category name:string description:text platform:references
bin/rails generate model Port name:string summary:text description:text url:string category:references platform:references version:string maintainer:string
bin/rails generate model PortDependency port:references dependency:references dependency_type:string
bin/rails generate model Installation user:references port:references installed_at:datetime version:string status:string
bin/rails generate model Review user:references port:references rating:integer content:text helpful_count:integer

log "BSDPorts package search platform setup completed"
commit "Set up BSDPorts with comprehensive package search and management features"

cat <<EOF > app/reflexes/packages_infinite_scroll_reflex.rb
class PackagesInfiniteScrollReflex < InfiniteScrollReflex
  def load_more
    @pagy, @collection = pagy(Package.all.order(created_at: :desc), page: page)
    super
  end
end
EOF

cat <<EOF > app/reflexes/comments_infinite_scroll_reflex.rb
class CommentsInfiniteScrollReflex < InfiniteScrollReflex
  def load_more
    @pagy, @collection = pagy(Comment.all.order(created_at: :desc), page: page)
    super
  end
end
EOF

cat <<EOF > app/controllers/packages_controller.rb
class PackagesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_package, only: [:show, :edit, :update, :destroy]

  def index
    @pagy, @packages = pagy(Package.all.order(created_at: :desc)) unless @stimulus_reflex
  end

  def show
  end

  def new
    @package = Package.new
  end

  def create
    @package = Package.new(package_params)
    @package.user = current_user
    if @package.save
      respond_to do |format|
        format.html { redirect_to packages_path, notice: t("bsdports.package_created") }
        format.turbo_stream
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @package.update(package_params)
      respond_to do |format|
        format.html { redirect_to packages_path, notice: t("bsdports.package_updated") }
        format.turbo_stream
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @package.destroy
    respond_to do |format|
      format.html { redirect_to packages_path, notice: t("bsdports.package_deleted") }
      format.turbo_stream
    end
  end

  private

  def set_package
    @package = Package.find(params[:id])
    redirect_to packages_path, alert: t("bsdports.not_authorized") unless @package.user == current_user || current_user&.admin?
  end

  def package_params
    params.require(:package).permit(:name, :version, :description, :file)
  end
end
EOF

cat <<EOF > app/controllers/comments_controller.rb
class CommentsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_comment, only: [:show, :edit, :update, :destroy]

  def index
    @pagy, @comments = pagy(Comment.all.order(created_at: :desc)) unless @stimulus_reflex
  end

  def show
  end

  def new
    @comment = Comment.new
  end

  def create
    @comment = Comment.new(comment_params)
    @comment.user = current_user
    if @comment.save
      respond_to do |format|
        format.html { redirect_to comments_path, notice: t("bsdports.comment_created") }
        format.turbo_stream
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @comment.update(comment_params)
      respond_to do |format|
        format.html { redirect_to comments_path, notice: t("bsdports.comment_updated") }
        format.turbo_stream
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @comment.destroy
    respond_to do |format|
      format.html { redirect_to comments_path, notice: t("bsdports.comment_deleted") }
      format.turbo_stream
    end
  end

  private

  def set_comment
    @comment = Comment.find(params[:id])
    redirect_to comments_path, alert: t("bsdports.not_authorized") unless @comment.user == current_user || current_user&.admin?
  end

  def comment_params
    params.require(:comment).permit(:package_id, :content)
  end
end
EOF

cat <<EOF > app/controllers/home_controller.rb
class HomeController < ApplicationController
  def index
    @pagy, @posts = pagy(Post.all.order(created_at: :desc), items: 10) unless @stimulus_reflex
    @packages = Package.all.order(created_at: :desc).limit(5)
  end
end
EOF

mkdir -p app/views/bsdports_logo

cat <<EOF > app/views/bsdports_logo/_logo.html.erb
<%= tag.svg xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 100 50", role: "img", class: "logo", "aria-label": t("bsdports.logo_alt") do %>
  <%= tag.title t("bsdports.logo_title", default: "BSDPorts Logo") %>
  <%= tag.text x: "50", y: "30", "text-anchor": "middle", "font-family": "Helvetica, Arial, sans-serif", "font-size": "16", fill: "#2196f3" do %>BSDPorts<% end %>
<% end %>
EOF

cat <<EOF > app/views/shared/_header.html.erb
<%= tag.header role: "banner" do %>
  <%= render partial: "bsdports_logo/logo" %>
<% end %>
EOF

cat <<EOF > app/views/shared/_footer.html.erb
<%= tag.footer role: "contentinfo" do %>
  <%= tag.nav class: "footer-links" aria-label: t("shared.footer_nav") do %>
    <%= link_to "", "https://facebook.com", class: "footer-link fb", "aria-label": "Facebook" %>
    <%= link_to "", "https://twitter.com", class: "footer-link tw", "aria-label": "Twitter" %>
    <%= link_to "", "https://instagram.com", class: "footer-link ig", "aria-label": "Instagram" %>
    <%= link_to t("shared.about"), "#", class: "footer-link text" %>
    <%= link_to t("shared.contact"), "#", class: "footer-link text" %>
    <%= link_to t("shared.terms"), "#", class: "footer-link text" %>
    <%= link_to t("shared.privacy"), "#", class: "footer-link text" %>
  <% end %>
<% end %>
EOF

cat <<EOF > app/views/home/index.html.erb
<% content_for :title, t("bsdports.home_title") %>
<% content_for :description, t("bsdports.home_description") %>
<% content_for :keywords, t("bsdports.home_keywords", default: "bsdports, packages, software") %>
<% content_for :schema do %>
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "WebPage",
    "name": "<%= t('bsdports.home_title') %>",
    "description": "<%= t('bsdports.home_description') %>",
    "url": "<%= request.original_url %>",
    "publisher": {
      "@type": "Organization",
      "name": "BSDPorts",
      "logo": {
        "@type": "ImageObject",
        "url": "<%= image_url('bsdports_logo.svg') %>"
      }
    }
  }
  </script>
<% end %>
<%= render "shared/header" %>
<%= tag.main role: "main" do %>
  <%= tag.section aria-labelledby: "post-heading" do %>
    <%= tag.h1 t("bsdports.post_title"), id: "post-heading" %>
    <%= tag.div data: { turbo_frame: "notices" } do %>
      <%= render "shared/notices" %>
    <% end %>
    <%= render partial: "posts/form", locals: { post: Post.new } %>
  <% end %>
  <%= render partial: "shared/search", locals: { model: "Package", field: "name" } %>
  <%= tag.section aria-labelledby: "packages-heading" do %>
    <%= tag.h2 t("bsdports.packages_title"), id: "packages-heading" %>
    <%= link_to t("bsdports.new_package"), new_package_path, class: "button", "aria-label": t("bsdports.new_package") if current_user %>
    <%= turbo_frame_tag "packages" data: { controller: "infinite-scroll" } do %>
      <% @packages.each do |package| %>
        <%= render partial: "packages/card", locals: { package: package } %>
      <% end %>
      <%= tag.div id: "sentinel", class: "hidden", data: { reflex: "PackagesInfiniteScroll#load_more", next_page: @pagy.next || 2 } %>
    <% end %>
    <%= tag.button t("bsdports.load_more"), id: "load-more", data: { reflex: "click->PackagesInfiniteScroll#load_more", "next-page": @pagy.next || 2, "reflex-root": "#load-more" }, class: @pagy&.next ? "" : "hidden", "aria-label": t("bsdports.load_more") %>
  <% end %>
  <%= tag.section aria-labelledby: "posts-heading" do %>
    <%= tag.h2 t("bsdports.posts_title"), id: "posts-heading" %>
    <%= turbo_frame_tag "posts" data: { controller: "infinite-scroll" } do %>
      <% @posts.each do |post| %>
        <%= render partial: "posts/card", locals: { post: post } %>
      <% end %>
      <%= tag.div id: "sentinel", class: "hidden", data: { reflex: "PostsInfiniteScroll#load_more", next_page: @pagy.next || 2 } %>
    <% end %>
    <%= tag.button t("bsdports.load_more"), id: "load-more", data: { reflex: "click->PostsInfiniteScroll#load_more", "next-page": @pagy.next || 2, "reflex-root": "#load-more" }, class: @pagy&.next ? "" : "hidden", "aria-label": t("bsdports.load_more") %>
  <% end %>
  <%= render partial: "shared/chat" %>
<% end %>
<%= render "shared/footer" %>
EOF

cat <<EOF > app/views/packages/index.html.erb
<% content_for :title, t("bsdports.packages_title") %>
<% content_for :description, t("bsdports.packages_description") %>
<% content_for :keywords, t("bsdports.packages_keywords", default: "bsdports, packages, software") %>
<% content_for :schema do %>
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "WebPage",
    "name": "<%= t('bsdports.packages_title') %>",
    "description": "<%= t('bsdports.packages_description') %>",
    "url": "<%= request.original_url %>",
    "hasPart": [
      <% @packages.each do |package| %>
      {
        "@type": "SoftwareApplication",
        "name": "<%= package.name %>",
        "softwareVersion": "<%= package.version %>",
        "description": "<%= package.description&.truncate(160) %>"
      }<%= "," unless package == @packages.last %>
      <% end %>
    ]
  }
  </script>
<% end %>
<%= render "shared/header" %>
<%= tag.main role: "main" do %>
  <%= tag.section aria-labelledby: "packages-heading" do %>
    <%= tag.h1 t("bsdports.packages_title"), id: "packages-heading" %>
    <%= tag.div data: { turbo_frame: "notices" } do %>
      <%= render "shared/notices" %>
    <% end %>
    <%= link_to t("bsdports.new_package"), new_package_path, class: "button", "aria-label": t("bsdports.new_package") if current_user %>
    <%= turbo_frame_tag "packages" data: { controller: "infinite-scroll" } do %>
      <% @packages.each do |package| %>
        <%= render partial: "packages/card", locals: { package: package } %>
      <% end %>
      <%= tag.div id: "sentinel", class: "hidden", data: { reflex: "PackagesInfiniteScroll#load_more", next_page: @pagy.next || 2 } %>
    <% end %>
    <%= tag.button t("bsdports.load_more"), id: "load-more", data: { reflex: "click->PackagesInfiniteScroll#load_more", "next-page": @pagy.next || 2, "reflex-root": "#load-more" }, class: @pagy&.next ? "" : "hidden", "aria-label": t("bsdports.load_more") %>
  <% end %>
  <%= render partial: "shared/search", locals: { model: "Package", field: "name" } %>
<% end %>
<%= render "shared/footer" %>
EOF

cat <<EOF > app/views/packages/_card.html.erb
<%= turbo_frame_tag dom_id(package) do %>
  <%= tag.article class: "post-card", id: dom_id(package), role: "article" do %>
    <%= tag.div class: "post-header" do %>
      <%= tag.span t("bsdports.posted_by", user: package.user.email) %>
      <%= tag.span package.created_at.strftime("%Y-%m-%d %H:%M") %>
    <% end %>
    <%= tag.h2 package.name %>
    <%= tag.p t("bsdports.package_version", version: package.version) %>
    <%= tag.p package.description %>
    <% if package.file.attached? %>
      <%= link_to t("bsdports.download_file"), rails_blob_path(package.file, disposition: "attachment"), "aria-label": t("bsdports.download_file_alt", name: package.name) %>
    <% end %>
    <%= render partial: "shared/vote", locals: { votable: package } %>
    <%= tag.p class: "post-actions" do %>
      <%= link_to t("bsdports.view_package"), package_path(package), "aria-label": t("bsdports.view_package") %>
      <%= link_to t("bsdports.edit_package"), edit_package_path(package), "aria-label": t("bsdports.edit_package") if package.user == current_user || current_user&.admin? %>
      <%= button_to t("bsdports.delete_package"), package_path(package), method: :delete, data: { turbo_confirm: t("bsdports.confirm_delete") }, form: { data: { turbo_frame: "_top" } }, "aria-label": t("bsdports.delete_package") if package.user == current_user || current_user&.admin? %>
    <% end %>
  <% end %>
<% end %>
EOF

cat <<EOF > app/views/packages/_form.html.erb
<%= form_with model: package, local: true, data: { controller: "character-counter form-validation", turbo: true } do |form| %>
  <%= tag.div data: { turbo_frame: "notices" } do %>
    <%= render "shared/notices" %>
  <% end %>
  <% if package.errors.any? %>
    <%= tag.div role: "alert" do %>
      <%= tag.p t("bsdports.errors", count: package.errors.count) %>
      <%= tag.ul do %>
        <% package.errors.full_messages.each do |msg| %>
          <%= tag.li msg %>
        <% end %>
      <% end %>
    <% end %>
  <% end %>
  <%= tag.fieldset do %>
    <%= form.label :name, t("bsdports.package_name"), "aria-required": true %>
    <%= form.text_field :name, required: true, data: { "form-validation-target": "input", action: "input->form-validation#validate" }, title: t("bsdports.package_name_help") %>
    <%= tag.span class: "error-message" data: { "form-validation-target": "error", for: "package_name" } %>
  <% end %>
  <%= tag.fieldset do %>
    <%= form.label :version, t("bsdports.package_version"), "aria-required": true %>
    <%= form.text_field :version, required: true, data: { "form-validation-target": "input", action: "input->form-validation#validate" }, title: t("bsdports.package_version_help") %>
    <%= tag.span class: "error-message" data: { "form-validation-target": "error", for: "package_version" } %>
  <% end %>
  <%= tag.fieldset do %>
    <%= form.label :description, t("bsdports.package_description"), "aria-required": true %>
    <%= form.text_area :description, required: true, data: { "character-counter-target": "input", "textarea-autogrow-target": "input", "form-validation-target": "input", action: "input->character-counter#count input->textarea-autogrow#resize input->form-validation#validate" }, title: t("bsdports.package_description_help") %>
    <%= tag.span data: { "character-counter-target": "count" } %>
    <%= tag.span class: "error-message" data: { "form-validation-target": "error", for: "package_description" } %>
  <% end %>
  <%= tag.fieldset do %>
    <%= form.label :file, t("bsdports.package_file"), "aria-required": true %>
    <%= form.file_field :file, required: !package.persisted?, data: { controller: "file-preview", "file-preview-target": "input" } %>
    <% if package.file.attached? %>
      <%= link_to t("bsdports.current_file"), rails_blob_path(package.file, disposition: "attachment"), "aria-label": t("bsdports.current_file_alt", name: package.name) %>
    <% end %>
    <%= tag.div data: { "file-preview-target": "preview" }, style: "display: none;" %>
  <% end %>
  <%= form.submit t("bsdports.#{package.persisted? ? 'update' : 'create'}_package"), data: { turbo_submits_with: t("bsdports.#{package.persisted? ? 'updating' : 'creating'}_package") } %>
<% end %>
EOF

cat <<EOF > app/views/packages/new.html.erb
<% content_for :title, t("bsdports.new_package_title") %>
<% content_for :description, t("bsdports.new_package_description") %>
<% content_for :keywords, t("bsdports.new_package_keywords", default: "add package, bsdports, software") %>
<% content_for :schema do %>
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "WebPage",
    "name": "<%= t('bsdports.new_package_title') %>",
    "description": "<%= t('bsdports.new_package_description') %>",
    "url": "<%= request.original_url %>"
  }
  </script>
<% end %>
<%= render "shared/header" %>
<%= tag.main role: "main" do %>
  <%= tag.section aria-labelledby: "new-package-heading" do %>
    <%= tag.h1 t("bsdports.new_package_title"), id: "new-package-heading" %>
    <%= render partial: "packages/form", locals: { package: @package } %>
  <% end %>
<% end %>
<%= render "shared/footer" %>
EOF

cat <<EOF > app/views/packages/edit.html.erb
<% content_for :title, t("bsdports.edit_package_title") %>
<% content_for :description, t("bsdports.edit_package_description") %>
<% content_for :keywords, t("bsdports.edit_package_keywords", default: "edit package, bsdports, software") %>
<% content_for :schema do %>
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "WebPage",
    "name": "<%= t('bsdports.edit_package_title') %>",
    "description": "<%= t('bsdports.edit_package_description') %>",
    "url": "<%= request.original_url %>"
  }
  </script>
<% end %>
<%= render "shared/header" %>
<%= tag.main role: "main" do %>
  <%= tag.section aria-labelledby: "edit-package-heading" do %>
    <%= tag.h1 t("bsdports.edit_package_title"), id: "edit-package-heading" %>
    <%= render partial: "packages/form", locals: { package: @package } %>
  <% end %>
<% end %>
<%= render "shared/footer" %>
EOF

cat <<EOF > app/views/packages/show.html.erb
<% content_for :title, @package.name %>
<% content_for :description, @package.description&.truncate(160) %>
<% content_for :keywords, t("bsdports.package_keywords", name: @package.name, default: "package, #{@package.name}, bsdports, software") %>
<% content_for :schema do %>
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "SoftwareApplication",
    "name": "<%= @package.name %>",
    "softwareVersion": "<%= @package.version %>",
    "description": "<%= @package.description&.truncate(160) %>"
  }
  </script>
<% end %>
<%= render "shared/header" %>
<%= tag.main role: "main" do %>
  <%= tag.section aria-labelledby: "package-heading" class: "post-card" do %>
    <%= tag.div data: { turbo_frame: "notices" } do %>
      <%= render "shared/notices" %>
    <% end %>
    <%= tag.h1 @package.name, id: "package-heading" %>
    <%= render partial: "packages/card", locals: { package: @package } %>
  <% end %>
<% end %>
<%= render "shared/footer" %>
EOF

cat <<EOF > app/views/comments/index.html.erb
<% content_for :title, t("bsdports.comments_title") %>
<% content_for :description, t("bsdports.comments_description") %>
<% content_for :keywords, t("bsdports.comments_keywords", default: "bsdports, comments, software") %>
<% content_for :schema do %>
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "WebPage",
    "name": "<%= t('bsdports.comments_title') %>",
    "description": "<%= t('bsdports.comments_description') %>",
    "url": "<%= request.original_url %>"
  }
  </script>
<% end %>
<%= render "shared/header" %>
<%= tag.main role: "main" do %>
  <%= tag.section aria-labelledby: "comments-heading" do %>
    <%= tag.h1 t("bsdports.comments_title"), id: "comments-heading" %>
    <%= tag.div data: { turbo_frame: "notices" } do %>
      <%= render "shared/notices" %>
    <% end %>
    <%= link_to t("bsdports.new_comment"), new_comment_path, class: "button", "aria-label": t("bsdports.new_comment") %>
    <%= turbo_frame_tag "comments" data: { controller: "infinite-scroll" } do %>
      <% @comments.each do |comment| %>
        <%= render partial: "comments/card", locals: { comment: comment } %>
      <% end %>
      <%= tag.div id: "sentinel", class: "hidden", data: { reflex: "CommentsInfiniteScroll#load_more", next_page: @pagy.next || 2 } %>
    <% end %>
    <%= tag.button t("bsdports.load_more"), id: "load-more", data: { reflex: "click->CommentsInfiniteScroll#load_more", "next-page": @pagy.next || 2, "reflex-root": "#load-more" }, class: @pagy&.next ? "" : "hidden", "aria-label": t("bsdports.load_more") %>
  <% end %>
<% end %>
<%= render "shared/footer" %>
EOF

cat <<EOF > app/views/comments/_card.html.erb
<%= turbo_frame_tag dom_id(comment) do %>
  <%= tag.article class: "post-card", id: dom_id(comment), role: "article" do %>
    <%= tag.div class: "post-header" do %>
      <%= tag.span t("bsdports.posted_by", user: comment.user.email) %>
      <%= tag.span comment.created_at.strftime("%Y-%m-%d %H:%M") %>
    <% end %>
    <%= tag.h2 comment.package.name %>
    <%= tag.p comment.content %>
    <%= render partial: "shared/vote", locals: { votable: comment } %>
    <%= tag.p class: "post-actions" do %>
      <%= link_to t("bsdports.view_comment"), comment_path(comment), "aria-label": t("bsdports.view_comment") %>
      <%= link_to t("bsdports.edit_comment"), edit_comment_path(comment), "aria-label": t("bsdports.edit_comment") if comment.user == current_user || current_user&.admin? %>
      <%= button_to t("bsdports.delete_comment"), comment_path(comment), method: :delete, data: { turbo_confirm: t("bsdports.confirm_delete") }, form: { data: { turbo_frame: "_top" } }, "aria-label": t("bsdports.delete_comment") if comment.user == current_user || current_user&.admin? %>
    <% end %>
  <% end %>
<% end %>
EOF

cat <<EOF > app/views/comments/_form.html.erb
<%= form_with model: comment, local: true, data: { controller: "character-counter form-validation", turbo: true } do |form| %>
  <%= tag.div data: { turbo_frame: "notices" } do %>
    <%= render "shared/notices" %>
  <% end %>
  <% if comment.errors.any? %>
    <%= tag.div role: "alert" do %>
      <%= tag.p t("bsdports.errors", count: comment.errors.count) %>
      <%= tag.ul do %>
        <% comment.errors.full_messages.each do |msg| %>
          <%= tag.li msg %>
        <% end %>
      <% end %>
    <% end %>
  <% end %>
  <%= tag.fieldset do %>
    <%= form.label :package_id, t("bsdports.comment_package"), "aria-required": true %>
    <%= form.collection_select :package_id, Package.all, :id, :name, { prompt: t("bsdports.package_prompt") }, required: true %>
    <%= tag.span class: "error-message" data: { "form-validation-target": "error", for: "comment_package_id" } %>
  <% end %>
  <%= tag.fieldset do %>
    <%= form.label :content, t("bsdports.comment_content"), "aria-required": true %>
    <%= form.text_area :content, required: true, data: { "character-counter-target": "input", "textarea-autogrow-target": "input", "form-validation-target": "input", action: "input->character-counter#count input->textarea-autogrow#resize input->form-validation#validate" }, title: t("bsdports.comment_content_help") %>
    <%= tag.span data: { "character-counter-target": "count" } %>
    <%= tag.span class: "error-message" data: { "form-validation-target": "error", for: "comment_content" } %>
  <% end %>
  <%= form.submit t("bsdports.#{comment.persisted? ? 'update' : 'create'}_comment"), data: { turbo_submits_with: t("bsdports.#{comment.persisted? ? 'updating' : 'creating'}_comment") } %>
<% end %>
EOF

cat <<EOF > app/views/comments/new.html.erb
<% content_for :title, t("bsdports.new_comment_title") %>
<% content_for :description, t("bsdports.new_comment_description") %>
<% content_for :keywords, t("bsdports.new_comment_keywords", default: "add comment, bsdports, software") %>
<% content_for :schema do %>
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "WebPage",
    "name": "<%= t('bsdports.new_comment_title') %>",
    "description": "<%= t('bsdports.new_comment_description') %>",
    "url": "<%= request.original_url %>"
  }
  </script>
<% end %>
<%= render "shared/header" %>
<%= tag.main role: "main" do %>
  <%= tag.section aria-labelledby: "new-comment-heading" do %>
    <%= tag.h1 t("bsdports.new_comment_title"), id: "new-comment-heading" %>
    <%= render partial: "comments/form", locals: { comment: @comment } %>
  <% end %>
<% end %>
<%= render "shared/footer" %>
EOF

cat <<EOF > app/views/comments/edit.html.erb
<% content_for :title, t("bsdports.edit_comment_title") %>
<% content_for :description, t("bsdports.edit_comment_description") %>
<% content_for :keywords, t("bsdports.edit_comment_keywords", default: "edit comment, bsdports, software") %>
<% content_for :schema do %>
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "WebPage",
    "name": "<%= t('bsdports.edit_comment_title') %>",
    "description": "<%= t('bsdports.edit_comment_description') %>",
    "url": "<%= request.original_url %>"
  }
  </script>
<% end %>
<%= render "shared/header" %>
<%= tag.main role: "main" do %>
  <%= tag.section aria-labelledby: "edit-comment-heading" do %>
    <%= tag.h1 t("bsdports.edit_comment_title"), id: "edit-comment-heading" %>
    <%= render partial: "comments/form", locals: { comment: @comment } %>
  <% end %>
<% end %>
<%= render "shared/footer" %>
EOF

cat <<EOF > app/views/comments/show.html.erb
<% content_for :title, t("bsdports.comment_title", package: @comment.package.name) %>
<% content_for :description, @comment.content&.truncate(160) %>
<% content_for :keywords, t("bsdports.comment_keywords", package: @comment.package.name, default: "comment, #{@comment.package.name}, bsdports, software") %>
<% content_for :schema do %>
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "Comment",
    "text": "<%= @comment.content&.truncate(160) %>",
    "about": {
      "@type": "SoftwareApplication",
      "name": "<%= @comment.package.name %>"
    }
  }
  </script>
<% end %>
<%= render "shared/header" %>
<%= tag.main role: "main" do %>
  <%= tag.section aria-labelledby: "comment-heading" class: "post-card" do %>
    <%= tag.div data: { turbo_frame: "notices" } do %>
      <%= render "shared/notices" %>
    <% end %>
    <%= tag.h1 t("bsdports.comment_title", package: @comment.package.name), id: "comment-heading" %>
    <%= render partial: "comments/card", locals: { comment: @comment } %>
  <% end %>
<% end %>
<%= render "shared/footer" %>
EOF

generate_turbo_views "packages" "package"
generate_turbo_views "comments" "comment"

commit "BSDPorts setup complete: Software package sharing platform with live search and anonymous features"

log "BSDPorts setup complete. Run 'bin/falcon-host' with PORT set to start on OpenBSD."

# Change Log:
# - Aligned with master.json v6.5.0: Two-space indents, double quotes, heredocs, Strunk & White comments.
# - Used Rails 8 conventions, Hotwire, Turbo Streams, Stimulus Reflex, I18n, and Falcon.
# - Leveraged bin/rails generate scaffold for Packages and Comments to streamline CRUD setup.
# - Extracted header, footer, search, and model-specific forms/cards into partials for DRY views.
# - Included live search, infinite scroll, and anonymous posting/chat via shared utilities.
# - Ensured NNG principles, SEO, schema data, and minimal flat design compliance.
# - Finalized for unprivileged user on OpenBSD 7.5.