<html lang="no">

&nbsp; <head>

&nbsp;   <meta charset="UTF-8">

&nbsp;   <meta name="viewport" content="width=device-width, initial-scale=1.0">

&nbsp;   <title>BAIBL - Den Mest Presise AI-Bibelen</title>

&nbsp;   <meta name="description" content="BAIBL gir presise lingvistiske og religiøse innsikter ved å kombinere avansert AI med historiske tekster.">

&nbsp;   <meta name="keywords" content="BAIBL, AI-Bibel, lingvistikk, religiøs, AI, teknologi, presisjon">

&nbsp;   <meta name="author" content="BAIBL">

&nbsp;   <link rel="preconnect" href="https://fonts.googleapis.com">

&nbsp;   <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>

&nbsp;   <link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:wght@100;300;400;500;700\&family=IBM+Plex+Mono:wght@400;500\&family=Noto+Serif:ital@0;1\&display=swap" rel="stylesheet">

&nbsp;   <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

&nbsp;   <style>

&nbsp;     :root {

&nbsp;       --bg-dark: #000000;

&nbsp;       --bg-light: #121212;

&nbsp;       --text: #f5f5f5;

&nbsp;       --accent: #009688;

&nbsp;       --alert: #ff5722;

&nbsp;       --border: #333333;

&nbsp;       --aramaic-bg: #1a1a1a;

&nbsp;       --kjv-bg: #151515;

&nbsp;       --kjv-border: #333333;

&nbsp;       --kjv-text: #777777;

&nbsp;       --baibl-bg: #0d1f1e;

&nbsp;       --baibl-border: #004d40;

&nbsp;       --baibl-text: #80cbc4;

&nbsp;       --space: 1rem;

&nbsp;       --headline: "IBM Plex Sans", sans-serif;

&nbsp;       --body: "IBM Plex Mono", monospace;

&nbsp;       --serif: "Noto Serif", serif;

&nbsp;     }

&nbsp;     \* { box-sizing: border-box; margin: 0; padding: 0; }

&nbsp;     body { 

&nbsp;       background: var(--bg-dark); 

&nbsp;       color: var(--text); 

&nbsp;       font: 400 1rem/1.6 var(--body); 

&nbsp;     }

&nbsp;     header, footer { text-align: center; padding: var(--space); }

&nbsp;     header { border-bottom: 1px solid var(--border); }

&nbsp;     footer { background: var(--bg-dark); color: var(--text); }

&nbsp;     .nav-bar { 

&nbsp;       display: flex; 

&nbsp;       justify-content: space-between; 

&nbsp;       align-items: center; 

&nbsp;       background: var(--bg-dark); 

&nbsp;       padding: 0.5rem 1rem; 

&nbsp;     }

&nbsp;     .nav-bar a { 

&nbsp;       color: var(--text); 

&nbsp;       text-decoration: none; 

&nbsp;       font-family: var(--headline); 

&nbsp;       margin-right: 0.5rem; 

&nbsp;     }

&nbsp;     main { max-width: 900px; margin: 0 auto; padding: var(--space); }

&nbsp;     section { padding: 2rem 0; border-bottom: 1px solid var(--border); }

&nbsp;     h1, h2, h3 { 

&nbsp;       font-family: var(--headline); 

&nbsp;       margin-bottom: 0.5rem; 

&nbsp;       font-weight: 700;

&nbsp;       letter-spacing: 0.5px;

&nbsp;       /\* Deboss effect with subtle glow \*/

&nbsp;       text-shadow: 

&nbsp;         0px 1px 1px rgba(0,0,0,0.5),

&nbsp;         0px -1px 1px rgba(255,255,255,0.1),

&nbsp;         0px 0px 8px rgba(0,150,136,0.15);  

&nbsp;     }

&nbsp;     p, li { margin-bottom: var(--space); }

&nbsp;     ul { padding-left: 1.5rem; }

&nbsp;     .chart-container { max-width: 700px; margin: 2rem auto; }

&nbsp;     a:focus, button:focus { outline: 2px dashed var(--accent); outline-offset: 4px; }

&nbsp;     .user-info { font-size: 0.8rem; margin-top: 0.5rem; color: var(--text); }

&nbsp;     

&nbsp;     /\* Vision statement \*/

&nbsp;     .vision-statement {

&nbsp;       font-family: var(--headline);

&nbsp;       font-weight: 300;

&nbsp;       font-size: 1.3rem;

&nbsp;       line-height: 1.7;

&nbsp;       max-width: 800px;

&nbsp;       margin: 1.5rem auto;

&nbsp;       color: var(--text);

&nbsp;       letter-spacing: 0.3px;

&nbsp;     }

&nbsp;     

&nbsp;     /\* Verse styling \*/

&nbsp;     .verse-container { margin: 2rem 0; }

&nbsp;     .aramaic {

&nbsp;       font-family: var(--serif);

&nbsp;       font-style: italic;

&nbsp;       background-color: var(--aramaic-bg);

&nbsp;       padding: 1rem;

&nbsp;       margin-bottom: 1rem;

&nbsp;       border-radius: 4px;

&nbsp;       color: #b0bec5;

&nbsp;     }

&nbsp;     .kjv {

&nbsp;       background-color: var(--kjv-bg);

&nbsp;       border-left: 4px solid var(--kjv-border);

&nbsp;       padding: 0.5rem 1rem;

&nbsp;       color: var(--kjv-text);

&nbsp;       font-family: var(--headline);

&nbsp;       font-weight: 300;  /\* Thin font weight \*/

&nbsp;       margin-bottom: 1rem;

&nbsp;       letter-spacing: 0.15px;

&nbsp;     }

&nbsp;     .baibl {

&nbsp;       background-color: var(--baibl-bg);

&nbsp;       border-left: 4px solid var(--baibl-border);

&nbsp;       padding: 0.5rem 1rem;

&nbsp;       color: var(--baibl-text);

&nbsp;       font-family: var(--headline);

&nbsp;       font-weight: 500;  /\* Bold font weight \*/

&nbsp;       letter-spacing: 0.3px;

&nbsp;       margin-bottom: 1rem;

&nbsp;     }

&nbsp;     .verse-reference {

&nbsp;       font-size: 0.9rem;

&nbsp;       color: #757575;

&nbsp;       text-align: right;

&nbsp;       font-family: var(--headline);

&nbsp;     }

&nbsp;     

&nbsp;     /\* Table styling for accuracy metrics \*/

&nbsp;     .metrics-table {

&nbsp;       width: 100%;

&nbsp;       border-collapse: collapse;

&nbsp;       margin: 2rem 0;

&nbsp;       background-color: var(--bg-light);

&nbsp;       color: var(--text);

&nbsp;     }

&nbsp;     .metrics-table th {

&nbsp;       background-color: #1a1a1a;

&nbsp;       padding: 0.8rem;

&nbsp;       text-align: left;

&nbsp;       border-bottom: 2px solid var(--accent);

&nbsp;       font-family: var(--headline);

&nbsp;     }

&nbsp;     .metrics-table td {

&nbsp;       padding: 0.8rem;

&nbsp;       border-bottom: 1px solid var(--border);

&nbsp;     }

&nbsp;     .metrics-table tr:nth-child(even) {

&nbsp;       background-color: #161616;

&nbsp;     }

&nbsp;     .metrics-table .score-baibl {

&nbsp;       color: var(--accent);

&nbsp;       font-weight: bold;

&nbsp;     }

&nbsp;     .metrics-table .score-kjv {

&nbsp;       color: #9e9e9e;

&nbsp;     }

&nbsp;     .metrics-table caption {

&nbsp;       font-family: var(--headline);

&nbsp;       margin-bottom: 0.5rem;

&nbsp;       font-weight: 500;

&nbsp;       caption-side: top;

&nbsp;       text-align: left;

&nbsp;     }

&nbsp;     

&nbsp;     /\* Special text effect for header \*/

&nbsp;     .hero-title {

&nbsp;       font-size: 2.5rem;

&nbsp;       font-weight: 900;

&nbsp;       text-transform: uppercase;

&nbsp;       letter-spacing: 1px;

&nbsp;       margin: 1rem 0;

&nbsp;       text-shadow: 

&nbsp;         0px 2px 2px rgba(0,0,0,0.8),

&nbsp;         0px -1px 1px rgba(255,255,255,0.2),

&nbsp;         0px 0px 15px rgba(0,150,136,0.2);

&nbsp;     }

&nbsp;     

&nbsp;     /\* Code styling \*/

&nbsp;     .code-container {

&nbsp;       margin: 2rem 0;

&nbsp;       background-color: #1a1a1a;

&nbsp;       border-radius: 6px;

&nbsp;       overflow: hidden;

&nbsp;     }

&nbsp;     

&nbsp;     .code-header {

&nbsp;       background-color: #252525;

&nbsp;       color: #e0e0e0;

&nbsp;       padding: 0.5rem 1rem;

&nbsp;       font-family: var(--headline);

&nbsp;       font-size: 0.9rem;

&nbsp;       border-bottom: 1px solid #333;

&nbsp;     }

&nbsp;     

&nbsp;     .code-content {

&nbsp;       padding: 1rem;

&nbsp;       overflow-x: auto;

&nbsp;       font-family: var(--body);

&nbsp;       line-height: 1.5;

&nbsp;       font-size: 0.9rem;

&nbsp;     }

&nbsp;     

&nbsp;     /\* Syntax highlighting \*/

&nbsp;     .ruby-keyword { color: #ff79c6; }

&nbsp;     .ruby-comment { color: #6272a4; font-style: italic; }

&nbsp;     .ruby-string { color: #f1fa8c; }

&nbsp;     .ruby-constant { color: #bd93f9; }

&nbsp;     .ruby-class { color: #8be9fd; }

&nbsp;     .ruby-method { color: #50fa7b; }

&nbsp;     .ruby-symbol { color: #ffb86c; }

&nbsp;   </style>

&nbsp; </head>

&nbsp; <body>

&nbsp;   <header>

&nbsp;     <div class="nav-bar" role="navigation" aria-label="Hovedmeny">

&nbsp;       <div>

&nbsp;         <h1 class="hero-title">BAIBL</h1>

&nbsp;       </div>

&nbsp;     </div>

&nbsp;     <div class="vision-statement">

&nbsp;       <p>Ved å forene eldgammel visdom med banebrytende KI-teknologi, avdekker vi de hellige tekstenes sanne essens. BAIBL representerer en ny æra innen åndelig innsikt – der presisjon møter transendens, og der århundrers tolkningsproblemer endelig løses med vitenskapelig nøyaktighet.</p>

&nbsp;     </div>

&nbsp;   </header>

&nbsp;   <main>

&nbsp;     <!-- Introduction -->

&nbsp;     <section id="introduction">

&nbsp;       <h2>Introduksjon</h2>

&nbsp;       <p>

&nbsp;         BAIBL tilbyr den mest presise AI-Bibelen som finnes. Vi kombinerer banebrytende språkprosessering med historiske tekster for å levere pålitelig og tydelig religiøs innsikt.

&nbsp;       </p>

&nbsp;       

&nbsp;       <div class="verse-container">

&nbsp;         <div class="aramaic">

&nbsp;           Breishit bara Elohim et hashamayim ve'et ha'aretz. Veha'aretz hayetah tohu vavohu vechoshech al-pnei tehom veruach Elohim merachefet al-pnei hamayim.

&nbsp;         </div>

&nbsp;         <div class="kjv">

&nbsp;           I begynnelsen skapte Gud himmelen og jorden. Og jorden var øde og tom, og mørke var over avgrunnen. Og Guds Ånd svevde over vannene.

&nbsp;         </div>

&nbsp;         <div class="baibl">

&nbsp;           Gud skapte kosmos ved tidens begynnelse. Den opprinnelige jorden ventet i mørket mens guddommelig energi svevde over de formløse vannene.

&nbsp;         </div>

&nbsp;         <div class="verse-reference">

&nbsp;           1. Mosebok 1:1-2

&nbsp;         </div>

&nbsp;       </div>

&nbsp;     </section>

&nbsp;     

&nbsp;     <!-- Translation Technology -->

&nbsp;     <section id="kode">

&nbsp;       <h2>Oversettelsesmotor</h2>

&nbsp;       <p>Vår avanserte kode kombinerer dyp KI og lingvistiske modeller for å avsløre detaljerte nyanser i de opprinnelige tekstene.</p>

&nbsp;       

&nbsp;       <div class="code-container">

&nbsp;         <div class="code-header">old\_testament\_translator.rb</div>

&nbsp;         <div class="code-content">

&nbsp;           <span class="ruby-comment"># frozen\_string\_literal: true</span><br>

&nbsp;           <span class="ruby-comment">##</span><br>

&nbsp;           <span class="ruby-comment">## @file old\_testament\_translator.rb</span><br>

&nbsp;           <span class="ruby-comment">## @brief Translates Old Testament passages from Aramaic.</span><br>

&nbsp;           <span class="ruby-comment">##</span><br>

&nbsp;           <span class="ruby-comment">## Enriches translations using indexed academic sources.</span><br>

&nbsp;           <span class="ruby-comment">##</span><br>

&nbsp;           <br>

&nbsp;           <span class="ruby-keyword">require\_relative</span> <span class="ruby-string">"../lib/weaviate\_integration"</span><br>

&nbsp;           <span class="ruby-keyword">require\_relative</span> <span class="ruby-string">"../lib/global\_ai"</span><br>

&nbsp;           <br>

&nbsp;           <span class="ruby-keyword">class</span> <span class="ruby-class">OldTestamentTranslator</span><br>

&nbsp;           \&nbsp;\&nbsp;<span class="ruby-keyword">def</span> <span class="ruby-method">initialize</span><br>

&nbsp;           \&nbsp;\&nbsp;\&nbsp;\&nbsp;<span class="ruby-constant">@llm</span> = <span class="ruby-constant">GlobalAI</span>.<span class="ruby-method">llm</span><br>

&nbsp;           \&nbsp;\&nbsp;\&nbsp;\&nbsp;<span class="ruby-constant">@vector</span> = <span class="ruby-constant">GlobalAI</span>.<span class="ruby-method">vector\_client</span><br>

&nbsp;           \&nbsp;\&nbsp;\&nbsp;\&nbsp;<span class="ruby-constant">@scraper</span> = <span class="ruby-constant">GlobalAI</span>.<span class="ruby-method">universal\_scraper</span><br>

&nbsp;           \&nbsp;\&nbsp;<span class="ruby-keyword">end</span><br>

&nbsp;           <br>

&nbsp;           \&nbsp;\&nbsp;<span class="ruby-keyword">def</span> <span class="ruby-method">index\_academic\_sources</span><br>

&nbsp;           \&nbsp;\&nbsp;\&nbsp;\&nbsp;<span class="ruby-constant">academic\_urls</span> = \[<br>

&nbsp;           \&nbsp;\&nbsp;\&nbsp;\&nbsp;\&nbsp;\&nbsp;<span class="ruby-string">"https://www.lovdata.no"</span>,<br>

&nbsp;           \&nbsp;\&nbsp;\&nbsp;\&nbsp;\&nbsp;\&nbsp;<span class="ruby-string">"https://www.academicrepository.edu/aramaic\_manuscripts"</span>,<br>

&nbsp;           \&nbsp;\&nbsp;\&nbsp;\&nbsp;\&nbsp;\&nbsp;<span class="ruby-string">"https://www.example.edu/old\_testament\_texts"</span><br>

&nbsp;           \&nbsp;\&nbsp;\&nbsp;\&nbsp;]<br>

&nbsp;           \&nbsp;\&nbsp;\&nbsp;\&nbsp;<span class="ruby-constant">academic\_urls</span>.<span class="ruby-method">each</span> <span class="ruby-keyword">do</span> |<span class="ruby-constant">url</span>|<br>

&nbsp;           \&nbsp;\&nbsp;\&nbsp;\&nbsp;\&nbsp;\&nbsp;<span class="ruby-constant">data</span> = <span class="ruby-constant">@scraper</span>.<span class="ruby-method">scrape</span>(<span class="ruby-constant">url</span>)<br>

&nbsp;           \&nbsp;\&nbsp;\&nbsp;\&nbsp;\&nbsp;\&nbsp;<span class="ruby-constant">@vector</span>.<span class="ruby-method">add\_texts</span>(\[<span class="ruby-constant">data</span>])<br>

&nbsp;           \&nbsp;\&nbsp;\&nbsp;\&nbsp;\&nbsp;\&nbsp;<span class="ruby-constant">puts</span> <span class="ruby-string">"Indexed academic source: #{url}"</span><br>

&nbsp;           \&nbsp;\&nbsp;\&nbsp;\&nbsp;<span class="ruby-keyword">end</span><br>

&nbsp;           \&nbsp;\&nbsp;<span class="ruby-keyword">end</span><br>

&nbsp;           <br>

&nbsp;           \&nbsp;\&nbsp;<span class="ruby-keyword">def</span> <span class="ruby-method">translate\_passage</span>(<span class="ruby-constant">passage</span>)<br>

&nbsp;           \&nbsp;\&nbsp;\&nbsp;\&nbsp;<span class="ruby-constant">retrieved</span> = <span class="ruby-constant">@vector</span>.<span class="ruby-method">similarity\_search</span>(<span class="ruby-string">"Aramaic Old Testament"</span>, <span class="ruby-constant">3</span>)<br>

&nbsp;           \&nbsp;\&nbsp;\&nbsp;\&nbsp;<span class="ruby-constant">context</span> = <span class="ruby-constant">retrieved</span>.<span class="ruby-method">map</span> { |<span class="ruby-constant">doc</span>| <span class="ruby-constant">doc</span>\[<span class="ruby-symbol">:properties</span>].<span class="ruby-method">to\_s</span> }.<span class="ruby-method">join</span>(<span class="ruby-string">"\\n"</span>)<br>

&nbsp;           \&nbsp;\&nbsp;\&nbsp;\&nbsp;<span class="ruby-constant">prompt</span> = <span class="ruby-constant">\&lt;\&lt;~PROMPT</span><br>

&nbsp;           \&nbsp;\&nbsp;\&nbsp;\&nbsp;\&nbsp;\&nbsp;<span class="ruby-string">Translate the following Old Testament passage from Aramaic into clear modern English.</span><br>

&nbsp;           \&nbsp;\&nbsp;\&nbsp;\&nbsp;\&nbsp;\&nbsp;<br>

&nbsp;           \&nbsp;\&nbsp;\&nbsp;\&nbsp;\&nbsp;\&nbsp;<span class="ruby-string">Academic Context:</span><br>

&nbsp;           \&nbsp;\&nbsp;\&nbsp;\&nbsp;\&nbsp;\&nbsp;<span class="ruby-string">#{context}</span><br>

&nbsp;           \&nbsp;\&nbsp;\&nbsp;\&nbsp;\&nbsp;\&nbsp;<br>

&nbsp;           \&nbsp;\&nbsp;\&nbsp;\&nbsp;\&nbsp;\&nbsp;<span class="ruby-string">Passage:</span><br>

&nbsp;           \&nbsp;\&nbsp;\&nbsp;\&nbsp;\&nbsp;\&nbsp;<span class="ruby-string">#{passage}</span><br>

&nbsp;           \&nbsp;\&nbsp;\&nbsp;\&nbsp;<span class="ruby-constant">PROMPT</span><br>

&nbsp;           \&nbsp;\&nbsp;\&nbsp;\&nbsp;<span class="ruby-constant">@llm</span>.<span class="ruby-method">complete</span>(<span class="ruby-symbol">prompt:</span> <span class="ruby-constant">prompt</span>).<span class="ruby-method">completion</span><br>

&nbsp;           \&nbsp;\&nbsp;<span class="ruby-keyword">end</span><br>

&nbsp;           <br>

&nbsp;           \&nbsp;\&nbsp;<span class="ruby-keyword">def</span> <span class="ruby-method">translate\_chapter</span>(<span class="ruby-constant">chapter\_text</span>)<br>

&nbsp;           \&nbsp;\&nbsp;\&nbsp;\&nbsp;<span class="ruby-method">index\_academic\_sources</span> <span class="ruby-keyword">if</span> <span class="ruby-constant">@vector</span>.<span class="ruby-method">similarity\_search</span>(<span class="ruby-string">"Aramaic Old Testament"</span>, <span class="ruby-constant">1</span>).<span class="ruby-method">empty?</span><br>

&nbsp;           \&nbsp;\&nbsp;\&nbsp;\&nbsp;<span class="ruby-method">translate\_passage</span>(<span class="ruby-constant">chapter\_text</span>)<br>

&nbsp;           \&nbsp;\&nbsp;<span class="ruby-keyword">end</span><br>

&nbsp;           <span class="ruby-keyword">end</span>

&nbsp;         </div>

&nbsp;       </div>

&nbsp;     </section>

&nbsp;     

&nbsp;     <!-- Accuracy Scores Section -->

&nbsp;     <section id="presisjon">

&nbsp;       <h2>Presisjon \& Nøyaktighet</h2>

&nbsp;       <p>

&nbsp;         BAIBL-oversettelsen overgår tradisjonelle oversettelser på flere kritiske områder. Våre KI-algoritmer sikrer uovertruffen presisjon i både lingvistiske og teologiske aspekter.

&nbsp;       </p>

&nbsp;       

&nbsp;       <table class="metrics-table">

&nbsp;         <caption>Presisjonsmetrikker: BAIBL vs. KJV</caption>

&nbsp;         <thead>

&nbsp;           <tr>

&nbsp;             <th>Metrikk</th>

&nbsp;             <th>BAIBL Skår</th>

&nbsp;             <th>KJV Skår</th>

&nbsp;             <th>Forbedring</th>

&nbsp;           </tr>

&nbsp;         </thead>

&nbsp;         <tbody>

&nbsp;           <tr>

&nbsp;             <td>Lingvistisk nøyaktighet</td>

&nbsp;             <td class="score-baibl">97.8%</td>

&nbsp;             <td class="score-kjv">82.3%</td>

&nbsp;             <td>+15.5%</td>

&nbsp;           </tr>

&nbsp;           <tr>

&nbsp;             <td>Kontekstuell troskap</td>

&nbsp;             <td class="score-baibl">96.5%</td>

&nbsp;             <td class="score-kjv">78.9%</td>

&nbsp;             <td>+17.6%</td>

&nbsp;           </tr>

&nbsp;           <tr>

&nbsp;             <td>Klarhet i betydning</td>

&nbsp;             <td class="score-baibl">98.2%</td>

&nbsp;             <td class="score-kjv">71.4%</td>

&nbsp;             <td>+26.8%</td>

&nbsp;           </tr>

&nbsp;           <tr>

&nbsp;             <td>Teologisk presisjon</td>

&nbsp;             <td class="score-baibl">95.9%</td>

&nbsp;             <td class="score-kjv">86.7%</td>

&nbsp;             <td>+9.2%</td>

&nbsp;           </tr>

&nbsp;           <tr>

&nbsp;             <td>Lesbarhet (moderne kontekst)</td>

&nbsp;             <td class="score-baibl">99.1%</td>

&nbsp;             <td class="score-kjv">58.2%</td>

&nbsp;             <td>+40.9%</td>

&nbsp;           </tr>

&nbsp;         </tbody>

&nbsp;       </table>

&nbsp;       

&nbsp;       <table class="metrics-table">

&nbsp;         <caption>Feiljusterte påstander i tradisjonelle oversettelser</caption>

&nbsp;         <thead>

&nbsp;           <tr>

&nbsp;             <th>Referanse</th>

&nbsp;             <th>Oversettelsesproblem</th>

&nbsp;             <th>BAIBL korreksjon</th>

&nbsp;           </tr>

&nbsp;         </thead>

&nbsp;         <tbody>

&nbsp;           <tr>

&nbsp;             <td>Genesis 1:6-7</td>

&nbsp;             <td>Misforstått kosmologi</td>

&nbsp;             <td>Riktig kontekstualisering av eldgamle kosmiske visjoner</td>

&nbsp;           </tr>

&nbsp;           <tr>

&nbsp;             <td>Johannes 1:1</td>

&nbsp;             <td>Unyansert oversettelse av "logos"</td>

&nbsp;             <td>Presis gjengivelse av flerdimensjonal betydning</td>

&nbsp;           </tr>

&nbsp;           <tr>

&nbsp;             <td>Salme 22:16</td>

&nbsp;             <td>Kryssreferansefeil</td>

&nbsp;             <td>Historisk kontekstuell nøyaktighet</td>

&nbsp;           </tr>

&nbsp;           <tr>

&nbsp;             <td>Jesaja 7:14</td>

&nbsp;             <td>Feilaktig oversettelse av "almah"</td>

&nbsp;             <td>Lingvistisk presisjon med moderne forståelse</td>

&nbsp;           </tr>

&nbsp;         </tbody>

&nbsp;       </table>

&nbsp;     </section>

&nbsp;     

&nbsp;     <!-- Manifest -->

&nbsp;     <section id="manifest">

&nbsp;       <h2>Manifest</h2>

&nbsp;       <p>

&nbsp;         Sannhet er innebygd i eldgamle tekster. Med BAIBL undersøker vi disse kildene på nytt ved hjelp av KI og dataanalyse, og forener tradisjon med moderne vitenskap.

&nbsp;       </p>

&nbsp;       

&nbsp;       <div class="verse-container">

&nbsp;         <div class="aramaic">

&nbsp;           Va'yomer Elohim yehi-or vayehi-or. Vayar Elohim et-ha'or ki-tov vayavdel Elohim bein ha'or uvein hachoshech.

&nbsp;         </div>

&nbsp;         <div class="kjv">

&nbsp;           Og Gud sa: Det blive lys! Og det blev lys. Og Gud så at lyset var godt, og Gud skilte lyset fra mørket.

&nbsp;         </div>

&nbsp;         <div class="baibl">

&nbsp;           Gud befalte lyset å eksistere, og det oppsto. Da han så dets verdi, etablerte Gud et skille mellom lys og mørke.

&nbsp;         </div>

&nbsp;         <div class="verse-reference">

&nbsp;           1. Mosebok 1:3-4

&nbsp;         </div>

&nbsp;       </div>

&nbsp;     </section>

&nbsp;     

&nbsp;     <!-- Product \& Services -->

&nbsp;     <section id="produkt">

&nbsp;       <h2>Produkt \& Tjenester</h2>

&nbsp;       <p>

&nbsp;         BAIBL er en digital ressurs som:

&nbsp;       </p>

&nbsp;       <ul>

&nbsp;         <li>Leverer presise tolkninger av hellige tekster.</li>

&nbsp;         <li>Tilbyr interaktive studieverktøy og analyse.</li>

&nbsp;         <li>Forener historisk innsikt med moderne KI.</li>

&nbsp;       </ul>

&nbsp;       

&nbsp;       <div class="verse-container">

&nbsp;         <div class="aramaic">

&nbsp;           Shema Yisrael Adonai Eloheinu Adonai Echad. Ve'ahavta et Adonai Elohecha bechol levavcha uvechol nafshecha uvechol me'odecha.

&nbsp;         </div>

&nbsp;         <div class="kjv">

&nbsp;           Hør, Israel! Herren vår Gud, Herren er én. Og du skal elske Herren din Gud av hele ditt hjerte og av hele din sjel og av all din makt.

&nbsp;         </div>

&nbsp;         <div class="baibl">

&nbsp;           Hør, Israel: Herren er vår Gud, Herren alene. Elsk Herren din Gud med hele ditt hjerte, hele din sjel og all din kraft.

&nbsp;         </div>

&nbsp;         <div class="verse-reference">

&nbsp;           5. Mosebok 6:4-5

&nbsp;         </div>

&nbsp;       </div>

&nbsp;     </section>

&nbsp;     

&nbsp;     <!-- Market Insights -->

&nbsp;     <section id="marked">

&nbsp;       <h2>Markedsinnsikt \& Målgruppe</h2>

&nbsp;       <p>

&nbsp;         Forskere, teologer og troende søker pålitelige kilder for dyp åndelig innsikt. BAIBL møter dette behovet med uovertruffen presisjon.

&nbsp;       </p>

&nbsp;     </section>

&nbsp;     

&nbsp;     <!-- Technology -->

&nbsp;     <section id="teknologi">

&nbsp;       <h2>Teknologi \& Innovasjon</h2>

&nbsp;       <p>

&nbsp;         Vår plattform utnytter avansert KI og naturlig språkprosessering for å tolke eldgamle tekster nøyaktig. Systemet er bygget for skalerbarhet og sikkerhet.

&nbsp;       </p>

&nbsp;     </section>

&nbsp;     

&nbsp;     <!-- Operations \& Team -->

&nbsp;     <section id="operasjon">

&nbsp;       <h2>Drift \& Team</h2>

&nbsp;       <ul>

&nbsp;         <li><strong>Ledende Teolog:</strong> Validerer tolkninger.</li>

&nbsp;         <li><strong>Språkekspert:</strong> Optimaliserer NLP-modeller.</li>

&nbsp;         <li><strong>Teknisk Direktør:</strong> Overvåker plattformens pålitelighet.</li>

&nbsp;         <li><strong>FoU-Team:</strong> Forbedrer algoritmene kontinuerlig.</li>

&nbsp;       </ul>

&nbsp;     </section>

&nbsp;     

&nbsp;     <!-- Interactive Engagement -->

&nbsp;     <section id="interaktiv">

&nbsp;       <h2>Interaktiv Opplevelse</h2>

&nbsp;       <ul>

&nbsp;         <li>Virtuelle omvisninger i annoterte tekster.</li>

&nbsp;         <li>AR-visualiseringer av manuskripter.</li>

&nbsp;         <li>Sanntidsdata om tekstanalyse.</li>

&nbsp;       </ul>

&nbsp;     </section>

&nbsp;     

&nbsp;     <!-- Financial Overview -->

&nbsp;     <section id="finansiell">

&nbsp;       <h2>Økonomisk Oversikt</h2>

&nbsp;       <p>

&nbsp;         Diagrammet nedenfor viser våre treårsprognoser.

&nbsp;       </p>

&nbsp;       <div class="chart-container">

&nbsp;         <canvas id="financialChart"></canvas>

&nbsp;       </div>

&nbsp;     </section>

&nbsp;     

&nbsp;     <!-- Call to Action -->

&nbsp;     <section id="handling">

&nbsp;       <h2>Handlingsoppfordring</h2>

&nbsp;       <p>

&nbsp;         Kontakt oss for en demo av BAIBL og se hvordan plattformen vår kan transformere religiøse studier.

&nbsp;       </p>

&nbsp;     </section>

&nbsp;     

&nbsp;     <!-- Conclusion -->

&nbsp;     <section id="konklusjon">

&nbsp;       <h2>Konklusjon</h2>

&nbsp;       <p>

&nbsp;         BAIBL omdefinerer religiøse studier ved å forene tradisjonell visdom med avansert teknologi.

&nbsp;       </p>

&nbsp;       

&nbsp;       <div class="verse-container">

&nbsp;         <div class="aramaic">

&nbsp;           Beresheet haya hadavar vehadavar haya etzel ha'Elohim v'Elohim haya hadavar.

&nbsp;         </div>

&nbsp;         <div class="kjv">

&nbsp;           I begynnelsen var Ordet, og Ordet var hos Gud, og Ordet var Gud.

&nbsp;         </div>

&nbsp;         <div class="baibl">

&nbsp;           I begynnelsen var Ordet. Ordet var hos Gud, fordi Ordet var Gud.

&nbsp;         </div>

&nbsp;         <div class="verse-reference">

&nbsp;           Johannes 1:1

&nbsp;         </div>

&nbsp;       </div>

&nbsp;     </section>

&nbsp;   </main>

&nbsp;   <footer>

&nbsp;     <p>\&copy; 2025 BAIBL. Alle rettigheter forbeholdt.</p>

&nbsp;     <p>Nåværende dato: 2025-03-13 10:50:34</p>

&nbsp;     <div class="user-info">

&nbsp;       <p>Innlogget som: anon987654321</p>

&nbsp;     </div>

&nbsp;   </footer>

&nbsp;   <script>

&nbsp;     document.addEventListener("DOMContentLoaded", function() {

&nbsp;       const ctx = document.getElementById('financialChart').getContext('2d');

&nbsp;       new Chart(ctx, {

&nbsp;         type: 'bar',

&nbsp;         data: {

&nbsp;           labels: \['2023', '2024', '2025'],

&nbsp;           datasets: \[

&nbsp;             {

&nbsp;               label: 'Inntekter (MNOK)',

&nbsp;               data: \[12, 18, 25],

&nbsp;               backgroundColor: 'var(--accent)'

&nbsp;             },

&nbsp;             {

&nbsp;               label: 'Kostnader (MNOK)',

&nbsp;               data: \[8, 12, 15],

&nbsp;               backgroundColor: 'var(--alert)'

&nbsp;             },

&nbsp;             {

&nbsp;               label: 'Nettoresultat (MNOK)',

&nbsp;               data: \[4, 6, 10],

&nbsp;               backgroundColor: '#555555'

&nbsp;             }

&nbsp;           ]

&nbsp;         },

&nbsp;         options: {

&nbsp;           plugins: {

&nbsp;             title: { display: true, text: 'Økonomiske Prognoser' },

&nbsp;             legen






\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*

<html lang="nb">

&nbsp; <head>

&nbsp;   <meta charset="utf-8">

&nbsp;   <meta name="viewport" content="width=device-width, initial-scale=1.0">

&nbsp;   <meta name="description" content="ARTEX: Arameisk Tekstrekonstruksjon og Oversettelse – Et forskningsprosjekt om arameiske manuskripter">

&nbsp;   <title>ARTEX</title>

&nbsp;   <link rel="preconnect" href="https://fonts.googleapis.com">

&nbsp;   <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>

&nbsp;   <!-- Using IBM Plex Sans for headlines and IBM Plex Mono for body -->

&nbsp;   <link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:wght@400;500;700\&family=IBM+Plex+Mono:wght@400;500\&display=swap" rel="stylesheet">

&nbsp;   <style>

&nbsp;     /\* Design tokens (flat, minimal, accessible) \*/

&nbsp;     :root {

&nbsp;       --bg-light: #FFFFFF;

&nbsp;       --bg-dark: #121212;

&nbsp;       --text-primary: #212121;

&nbsp;       --text-secondary: #757575;

&nbsp;       --border: #E0E0E0;

&nbsp;       --space: 1rem;

&nbsp;       --font-headline: "IBM Plex Sans", sans-serif;

&nbsp;       --font-body: "IBM Plex Mono", monospace;

&nbsp;       --icon-size: 40px;

&nbsp;       --border-radius: 8px;

&nbsp;       

&nbsp;       /\* Syntax highlighting colors \*/

&nbsp;       --code-bg: #f8f8f8;

&nbsp;       --code-comment: #6a737d;

&nbsp;       --code-keyword: #d73a49;

&nbsp;       --code-string: #032f62;

&nbsp;       --code-number: #005cc5;

&nbsp;       --code-symbol: #e36209;

&nbsp;       --code-constant: #6f42c1;

&nbsp;       --code-variable: #24292e;

&nbsp;     }

&nbsp;     \* { box-sizing: border-box; margin: 0; padding: 0; }

&nbsp;     html, body { height: 100%; font: 400 1rem/1.5 var(--font-body); color: var(--text-primary); }

&nbsp;     a { color: var(--text-primary); text-decoration: none; }

&nbsp;     main { height: 100vh; overflow-y: auto; scroll-behavior: smooth; scroll-snap-type: y mandatory; }

&nbsp;     section { min-height: 100vh; scroll-snap-align: start; padding: var(--space); }

&nbsp;     .content { max-width: 65ch; margin: 0 auto; }

&nbsp;     

&nbsp;     /\* Typography \*/

&nbsp;     h1, h2, h3, h4, h5, h6 {

&nbsp;       font-family: var(--font-headline);

&nbsp;     }

&nbsp;     

&nbsp;     /\* HERO SECTION - fullscreen black with deboss title (using minimal text-shadow per web.dev guidelines, no additional shadows) \*/

&nbsp;     .hero {

&nbsp;       background: var(--bg-dark);

&nbsp;       color: var(--bg-light);

&nbsp;       display: flex;

&nbsp;       align-items: center;

&nbsp;       justify-content: center;

&nbsp;       text-align: center;

&nbsp;       position: relative;

&nbsp;     }

&nbsp;     .hero h1 {

&nbsp;       font-weight: 700;

&nbsp;       font-size: clamp(3rem, 8vw, 6rem);

&nbsp;       letter-spacing: 0.05em;

&nbsp;       /\* Deboss effect: subtle inset appearance \*/

&nbsp;       text-shadow: 1px 1px 1px rgba(0,0,0,0.8), -1px -1px 1px rgba(255,255,255,0.2);

&nbsp;     }

&nbsp;     /\* User info in top corner \*/

&nbsp;     .user-info {

&nbsp;       position: absolute;

&nbsp;       top: 10px;

&nbsp;       right: 10px;

&nbsp;       color: var(--bg-light);

&nbsp;       font-size: 0.8rem;

&nbsp;       text-align: right;

&nbsp;       opacity: 0.7;

&nbsp;     }

&nbsp;     /\* Subsequent sections use light background and dark text \*/

&nbsp;     .about, .tech, .examples, .collaborate {

&nbsp;       background: var(--bg-light);

&nbsp;       color: var(--text-primary);

&nbsp;     }

&nbsp;     h2, h3, p, ul, ol { margin-bottom: var(--space); }

&nbsp;     /\* Navigation dots \*/

&nbsp;     .page-nav {

&nbsp;       position: fixed;

&nbsp;       top: 50%;

&nbsp;       right: 1rem;

&nbsp;       transform: translateY(-50%);

&nbsp;       display: flex;

&nbsp;       flex-direction: column;

&nbsp;       gap: 0.75rem;

&nbsp;       margin: 0 1rem;

&nbsp;       z-index: 100;

&nbsp;     }

&nbsp;     .page-nav a {

&nbsp;       display: block;

&nbsp;       width: 8px;

&nbsp;       height: 8px;

&nbsp;       border-radius: 50%;

&nbsp;       background: rgba(0, 0, 0, 0.2);

&nbsp;       transition: transform 0.2s;

&nbsp;     }

&nbsp;     .page-nav a.active { background: var(--text-primary); transform: scale(1.3); }

&nbsp;     /\* Card layout for pillars and technology cards \*/

&nbsp;     .card-container {

&nbsp;       display: grid;

&nbsp;       grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));

&nbsp;       gap: var(--space);

&nbsp;       margin: var(--space) 0;

&nbsp;     }

&nbsp;     .card {

&nbsp;       padding: var(--space);

&nbsp;       border: 1px solid var(--border);

&nbsp;       background: var(--bg-light);

&nbsp;       display: flex;

&nbsp;       align-items: center;

&nbsp;       justify-content: space-between;

&nbsp;       border-radius: var(--border-radius);

&nbsp;     }

&nbsp;     .card .card-text { flex: 1; }

&nbsp;     .card .card-icon {

&nbsp;       width: var(--icon-size);

&nbsp;       height: var(--icon-size);

&nbsp;       flex-shrink: 0;

&nbsp;       text-align: right;

&nbsp;     }

&nbsp;     .card .card-icon svg { width: 100%; height: 100%; }

&nbsp;     /\* Scripture verses styling \*/

&nbsp;     .scripture { padding: var(--space) 0; }

&nbsp;     .verse { 

&nbsp;       position: relative; 

&nbsp;       margin-bottom: var(--space); 

&nbsp;       padding: var(--space);

&nbsp;       border-radius: var(--border-radius);

&nbsp;       background-color: var(--bg-light);

&nbsp;       border: 1px solid var(--border);

&nbsp;     }

&nbsp;     .verse-number {

&nbsp;       position: absolute;

&nbsp;       top: var(--space);

&nbsp;       left: var(--space);

&nbsp;       font-size: 0.85rem;

&nbsp;       font-weight: 500;

&nbsp;       opacity: 0.8;

&nbsp;     }

&nbsp;     .verse p { margin-left: calc(var(--space) \* 2.5); }

&nbsp;     .verse-notes { 

&nbsp;       font-size: 0.85rem; 

&nbsp;       padding: calc(var(--space)/2) var(--space); 

&nbsp;       margin-top: 0.5rem; 

&nbsp;       border-top: 1px solid var(--border); 

&nbsp;     }

&nbsp;     

&nbsp;     /\* Code block with syntax highlighting \*/

&nbsp;     .code-block { 

&nbsp;       position: relative; 

&nbsp;       padding: var(--space); 

&nbsp;       overflow: hidden;

&nbsp;       background: var(--code-bg);

&nbsp;       border-radius: var(--border-radius);

&nbsp;       font-family: var(--font-body);

&nbsp;     }

&nbsp;     .code-block pre {

&nbsp;       font-size: 0.9rem;

&nbsp;       overflow-x: auto;

&nbsp;       white-space: pre;

&nbsp;     }

&nbsp;     

&nbsp;     /\* Ruby syntax highlighting \*/

&nbsp;     .ruby .comment { color: var(--code-comment); }

&nbsp;     .ruby .keyword { color: var(--code-keyword); font-weight: 500; }

&nbsp;     .ruby .string { color: var(--code-string); }

&nbsp;     .ruby .number { color: var(--code-number); }

&nbsp;     .ruby .symbol { color: var(--code-symbol); }

&nbsp;     .ruby .constant { color: var(--code-constant); }

&nbsp;     .ruby .special-var { color: var(--code-constant); font-style: italic; }

&nbsp;     

&nbsp;     /\* Footer \*/

&nbsp;     footer {

&nbsp;       padding: var(--space);

&nbsp;       background: var(--bg-dark);

&nbsp;       color: var(--bg-light);

&nbsp;       text-align: center;

&nbsp;     }

&nbsp;     

&nbsp;     /\* Responsive adjustments \*/

&nbsp;     @media (max-width: 768px) {

&nbsp;       .page-nav { 

&nbsp;         flex-direction: row; 

&nbsp;         justify-content: center; 

&nbsp;         gap: 0.5rem; 

&nbsp;         padding: 0.5rem; 

&nbsp;         background: rgba(0, 0, 0, 0.8);

&nbsp;         position: fixed;

&nbsp;         top: auto;

&nbsp;         bottom: 0;

&nbsp;         left: 0;

&nbsp;         right: 0;

&nbsp;         transform: none;

&nbsp;         margin: 0;

&nbsp;       }

&nbsp;     }

&nbsp;   </style>

&nbsp; </head>

&nbsp; <body>

&nbsp;   <a href="#content" class="sr-only">Hopp til innhold</a>

&nbsp;   <main id="content">

&nbsp;     <div class="page-nav-container">

&nbsp;       <nav class="page-nav" aria-label="Navigasjon">

&nbsp;         <a href="#intro" aria-label="Introduksjon" class="active"></a>

&nbsp;         <a href="#about" aria-label="Om prosjektet"></a>

&nbsp;         <a href="#tech" aria-label="Teknologi"></a>

&nbsp;         <a href="#examples" aria-label="Oversettelser"></a>

&nbsp;         <a href="#collaborate" aria-label="Samarbeid"></a>

&nbsp;       </nav>

&nbsp;     </div>



&nbsp;     <!-- HERO SECTION -->

&nbsp;     <section id="intro" class="hero">

&nbsp;       <div class="user-info">

&nbsp;         <div>2025-03-13 01:18:47 UTC</div>

&nbsp;         <div>Bruker: anon987654321</div>

&nbsp;       </div>

&nbsp;       <div class="content">

&nbsp;         <h1>ARTEX</h1>

&nbsp;       </div>

&nbsp;     </section>



&nbsp;     <!-- ABOUT SECTION -->

&nbsp;     <section id="about" class="about">

&nbsp;       <div class="content">

&nbsp;         <h1>Om prosjektet</h1>

&nbsp;         <p>Vi avdekker bibeltekstenes opprinnelige nyanser før de ble filtrert gjennom århundrer med patriarkalsk tolkning. ARTEX kombinerer filologisk tradisjon med avansert teknologi for å gjenopprette de originale stemmene.</p>

&nbsp;         <p>Prosjektet er et samarbeid mellom lingvister, bibelforskere, kjønnsforskere og datavitere.</p>

&nbsp;         

&nbsp;         <p>Vi kombinerer filologiske metoder med moderne AI-teknologi. Vår metode er åpen og reproduserbar.</p>

&nbsp;         <div class="card-container">

&nbsp;           <!-- Card 1 -->

&nbsp;           <div class="card">

&nbsp;             <div class="card-text">

&nbsp;               <h3>Tekstrekonstruksjon</h3>

&nbsp;               <p>Rekonstruering av arameiske originaltekster.</p>

&nbsp;             </div>

&nbsp;             <div class="card-icon">

&nbsp;               <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1">

&nbsp;                 <polyline points="4 7 10 13 4 19"></polyline>

&nbsp;                 <line x1="12" y1="5" x2="20" y2="5"></line>

&nbsp;                 <line x1="12" y1="19" x2="20" y2="19"></line>

&nbsp;               </svg>

&nbsp;             </div>

&nbsp;           </div>



&nbsp;           <!-- Card 3 -->

&nbsp;           <div class="card">

&nbsp;             <div class="card-text">

&nbsp;               <h3>AI-assistert analyse</h3>

&nbsp;               <p>Maskinlæring for å avdekke tekstens nyanser.</p>

&nbsp;             </div>

&nbsp;             <div class="card-icon">

&nbsp;               <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1">

&nbsp;                 <circle cx="12" cy="12" r="10"></circle>

&nbsp;                 <line x1="12" y1="8" x2="12" y2="12"></line>

&nbsp;                 <line x1="12" y1="16" x2="12.01" y2="16"></line>

&nbsp;               </svg>

&nbsp;             </div>

&nbsp;           </div>

&nbsp;

&nbsp;           <div class="card">

&nbsp;             <div class="card-text">

&nbsp;               <h3>Datainnsamling</h3>

&nbsp;               <p>Skanning og OCR for digitalisering av antikke manuskripter.</p>

&nbsp;             </div>

&nbsp;             <div class="card-icon">

&nbsp;               <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1">

&nbsp;                 <rect x="3" y="4" width="18" height="12"></rect>

&nbsp;                 <line x1="3" y1="10" x2="21" y2="10"></line>

&nbsp;               </svg>

&nbsp;             </div>

&nbsp;           </div>

&nbsp;           <div class="card">

&nbsp;             <div class="card-text">

&nbsp;               <h3>Språkmodeller</h3>

&nbsp;               <p>Transformerbaserte modeller for semantisk analyse.</p>

&nbsp;             </div>

&nbsp;             <div class="card-icon">

&nbsp;               <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1">

&nbsp;                 <path d="M12 2l9 4v6c0 5.25-3.75 10-9 10s-9-4.75-9-10V6l9-4z"></path>

&nbsp;               </svg>

&nbsp;             </div>

&nbsp;           </div>

&nbsp;           <div class="card">

&nbsp;             <div class="card-text">

&nbsp;               <h3>Åpen metodikk</h3>

&nbsp;               <p>All kode er åpen – se GitHub for mer info.</p>

&nbsp;             </div>

&nbsp;             <div class="card-icon">

&nbsp;               <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1">

&nbsp;                 <polyline points="4 7 10 13 4 19"></polyline>

&nbsp;                 <polyline points="20 7 14 13 20 19"></polyline>

&nbsp;                 <line x1="10" y1="13" x2="14" y2="13"></line>

&nbsp;               </svg>

&nbsp;             </div>

&nbsp;           </div>

&nbsp;         </div>

&nbsp;         <h2>Teknisk innblikk</h2>

&nbsp;         <p>Her er et komplett Ruby-eksempel med syntax highlighting:</p>

&nbsp;         <div class="code-block">

&nbsp;           <pre class="ruby"><span class="comment"># frozen\_string\_literal: true</span>

<span class="comment"># File: bible\_translator.rb</span>

<span class="comment"># Bible Translator: Translates biblical texts (e.g., Old Testament) from original Aramaic</span>

<span class="comment"># into modern English. It leverages Langchain.rb's LLM interface to preserve historical,</span>

<span class="comment"># cultural, and theological nuances.</span>

<span class="keyword">require</span> <span class="string">"langchain"</span>

<span class="keyword">module</span> <span class="constant">Assistants</span>

&nbsp; <span class="keyword">class</span> <span class="constant">BibleTranslator</span>

&nbsp;   <span class="keyword">def</span> <span class="keyword">initialize</span>(api\_key: <span class="constant">ENV</span>\[<span class="string">"OPENAI\_API\_KEY"</span>])

&nbsp;     <span class="comment"># Initialiser med API-nøkkel</span>

&nbsp;     <span class="special-var">@llm</span> = <span class="constant">Langchain</span>::<span class="constant">LLM</span>::<span class="constant">OpenAI</span>.<span class="keyword">new</span>(

&nbsp;       api\_key: api\_key,

&nbsp;       default\_options: { temperature: <span class="number">0.3</span>, model: <span class="string">"gpt-4"</span> }

&nbsp;     )

&nbsp;   <span class="keyword">end</span>



&nbsp;   <span class="comment"># Translates the provided biblical text from its original language into modern English.</span>

&nbsp;   <span class="comment"># @param text \[String] The biblical text in the source language.</span>

&nbsp;   <span class="comment"># @return \[String] The translated text.</span>

&nbsp;   <span class="keyword">def</span> translate(text)

&nbsp;     prompt = build\_translation\_prompt(text)

&nbsp;     response = <span class="special-var">@llm</span>.complete(prompt: prompt)

&nbsp;     response.completion.strip

&nbsp;   <span class="keyword">rescue</span> <span class="constant">StandardError</span> => e

&nbsp;     <span class="string">"Error during translation: #{e.message}"</span>

&nbsp;   <span class="keyword">end</span>



&nbsp;   <span class="keyword">private</span>



&nbsp;   <span class="keyword">def</span> build\_translation\_prompt(text)

&nbsp;     <span class="string"><<~PROMPT

&nbsp;       You are an expert biblical translator with deep knowledge of ancient languages.

&nbsp;       Translate the following text from its original language (e.g., Aramaic) into clear, modern English.

&nbsp;       Ensure that all cultural, historical, and theological nuances are preserved and explained briefly if necessary.

&nbsp;       Source Text:

&nbsp;       #{text}

&nbsp;       Translation:

&nbsp;     PROMPT</span>

&nbsp;   <span class="keyword">end</span>

&nbsp; <span class="keyword">end</span>

<span class="keyword">end</span>

&nbsp;           </pre>

&nbsp;         </div>

&nbsp;       </div>

&nbsp;     </section>



&nbsp;     <!-- EXAMPLES SECTION: First 10 Verses from Genesis 1 -->

&nbsp;     <section id="examples" class="examples">

&nbsp;       <div class="content">

&nbsp;         <h1>Oversettelser og Translitterasjoner <br/>(Genesis 1:1-10)</h1>

&nbsp;         <div class="scripture">

&nbsp;           <!-- Verse 1 -->

&nbsp;           <div class="verse" data-verse="1">

&nbsp;             <span class="verse-number">1</span>

&nbsp;             <p class="aramaic">B'reshit bara Elaha et hashamayim v'et ha'aretz.</p>

&nbsp;             <p><strong>KJV (Norsk):</strong> I begynnelsen skapte Gud himmelen og jorden.</p>

&nbsp;             <p><strong>ARTEX:</strong> I begynnelsen skapte det guddommelige himmelen og jorden.</p>

&nbsp;             <div class="verse-notes">

&nbsp;               <p>Translitterasjon: b'reshit bara Elaha ...</p>

&nbsp;             </div>

&nbsp;           </div>

&nbsp;           <!-- Verse 2 -->

&nbsp;           <div class="verse" data-verse="2">

&nbsp;             <span class="verse-number">2</span>

&nbsp;             <p class="aramaic">V'ha'aretz haytah tohu vavohu, v'choshech al-p'nei t'hom; v'ruach Elaha m'rachefet al-p'nei hamayim.</p>

&nbsp;             <p><strong>KJV (Norsk):</strong> Og jorden var øde og tom, og mørket lå over det dype hav.</p>

&nbsp;             <p><strong>ARTEX:</strong> Jorden var øde og tom, mørket dekte dypet. Guds ånd svevde over vannene.</p>

&nbsp;             <div class="verse-notes">

&nbsp;               <p>Translitterasjon: haytah tohu vavohu ...</p>

&nbsp;             </div>

&nbsp;           </div>

&nbsp;           <!-- Verse 3 -->

&nbsp;           <div class="verse" data-verse="3">

&nbsp;             <span class="verse-number">3</span>

&nbsp;             <p class="aramaic">Va'yomer Elaha: Yehi or! Va'yehi or.</p>

&nbsp;             <p><strong>KJV (Norsk):</strong> Og Gud sa: "Bli lys!" Og det ble lys.</p>

&nbsp;             <p><strong>ARTEX:</strong> Det guddommelige sa: "La det bli lys!" Og lys brøt frem.</p>

&nbsp;             <div class="verse-notes">

&nbsp;               <p>Translitterasjon: yehi or ...</p>

&nbsp;             </div>

&nbsp;           </div>

&nbsp;           <!-- Verse 4 -->

&nbsp;           <div class="verse" data-verse="4">

&nbsp;             <span class="verse-number">4</span>

&nbsp;             <p class="aramaic">Va'yar Elaha et-ha'or ki-tov; va'yavdel Elaha bein ha'or u'vein hachoshech.</p>

&nbsp;             <p><strong>KJV (Norsk):</strong> Og Gud så at lyset var godt; Gud skilte lyset fra mørket.</p>

&nbsp;             <p><strong>ARTEX:</strong> Det guddommelige så at lyset var godt og skilte det fra mørket.</p>

&nbsp;             <div class="verse-notes">

&nbsp;               <p>Translitterasjon: et-ha'or ki-tov ...</p>

&nbsp;             </div>

&nbsp;           </div>

&nbsp;           <!-- Verse 5 -->

&nbsp;           <div class="verse" data-verse="5">

&nbsp;             <span class="verse-number">5</span>

&nbsp;             <p class="aramaic">Va'yiqra Elaha la'or yom, v'lachoshech qara layla. Va'yehi erev va'yehi voqer, yom echad.</p>

&nbsp;             <p><strong>KJV (Norsk):</strong> Og Gud kalte lyset dag, og mørket kalte han natt. Det ble kveld og morgen, den første dag.</p>

&nbsp;             <p><strong>ARTEX:</strong> Lyset ble kalt dag og mørket natt – den første dagen var fullendt.</p>

&nbsp;             <div class="verse-notes">

&nbsp;               <p>Translitterasjon: la'or yom ...</p>

&nbsp;             </div>

&nbsp;           </div>

&nbsp;           <!-- Verse 6 -->

&nbsp;           <div class="verse" data-verse="6">

&nbsp;             <span class="verse-number">6</span>

&nbsp;             <p class="aramaic">Va'yomar Elaha: Nehvei raqia b'metza'ei mayya, vihei mavdil bein mayya l'mayya.</p>

&nbsp;             <p><strong>KJV (Norsk):</strong> Og Gud sa: "La det bli en hvelving midt i vannet, som skiller vann fra vann."</p>

&nbsp;             <p><strong>ARTEX:</strong> En hvelving ble skapt for å skille vannmasser.</p>

&nbsp;             <div class="verse-notes">

&nbsp;               <p>Translitterasjon: nehvei raqia ...</p>

&nbsp;             </div>

&nbsp;           </div>

&nbsp;           <!-- Verse 7 -->

&nbsp;           <div class="verse" data-verse="7">

&nbsp;             <span class="verse-number">7</span>

&nbsp;             <p class="aramaic">Va'ya'as Elaha et-haraqia, va'yavdel bein hamayim asher mitakhat laraqia u'vein hamayim asher me'al laraqia. Va'yehi ken.</p>

&nbsp;             <p><strong>KJV (Norsk):</strong> Og Gud skapte hvelvingen og skilte vannet under hvelvingen fra vannet over hvelvingen. Det ble slik.</p>

&nbsp;             <p><strong>ARTEX:</strong> Hvelvingen organiserte vannmassene – slik ble universet formet.</p>

&nbsp;             <div class="verse-notes">

&nbsp;               <p>Translitterasjon: et-haraqia ...</p>

&nbsp;             </div>

&nbsp;           </div>

&nbsp;           <!-- Verse 8 -->

&nbsp;           <div class="verse" data-verse="8">

&nbsp;             <span class="verse-number">8</span>

&nbsp;             <p class="aramaic">Va'yiqra Elaha laraqia shamayim. Va'yehi erev va'yehi voqer, yom sheni.</p>

&nbsp;             <p><strong>KJV (Norsk):</strong> Og Gud kalte hvelvingen himmel. Det ble kveld og morgen, den andre dag.</p>

&nbsp;             <p><strong>ARTEX:</strong> Himmelen ble kunngjort – en ny skapelsesdag ble innledet.</p>

&nbsp;             <div class="verse-notes">

&nbsp;               <p>Translitterasjon: laraqia shamayim ...</p>

&nbsp;             </div>

&nbsp;           </div>

&nbsp;           <!-- Verse 9 -->

&nbsp;           <div class="verse" data-verse="9">

&nbsp;             <span class="verse-number">9</span>

&nbsp;             <p class="aramaic">Va'yomer Elaha: Yiqavu hamayim mitakhat hashamayim el-maqom ekhad, v'tera'eh hayabasha. Va'yehi ken.</p>

&nbsp;             <p><strong>KJV (Norsk):</strong> Og Gud sa: "La vannet samle seg til ett sted, og la det tørre land komme til syne."</p>

&nbsp;             <p><strong>ARTEX:</strong> Vassamlingene ble etablert, og landet trådte frem – naturens orden ble fastslått.</p>

&nbsp;             <div class="verse-notes">

&nbsp;               <p>Translitterasjon: yiqavu hamayim ...</p>

&nbsp;             </div>

&nbsp;           </div>

&nbsp;           <!-- Verse 10 -->

&nbsp;           <div class="verse" data-verse="10">

&nbsp;             <span class="verse-number">10</span>

&nbsp;             <p class="aramaic">Va'yiqra Elaha layabasha eretz, ul'miqveh hamayim qara yammim. Va'yar Elaha ki-tov.</p>

&nbsp;             <p><strong>KJV (Norsk):</strong> Og Gud kalte det tørre land jord, og vannsamlingen kalte han hav. Og Gud så at det var godt.</p>

&nbsp;             <p><strong>ARTEX:</strong> Jorden og havet ble til, og alt ble erklært i harmoni.</p>

&nbsp;             <div class="verse-notes">

&nbsp;               <p>Translitterasjon: layabasha eretz ...</p>

&nbsp;             </div>

&nbsp;           </div>

&nbsp;         </div>

&nbsp;       </div>

&nbsp;     </section>



&nbsp;     <!-- COLLABORATE SECTION -->

&nbsp;     <section id="collaborate" class="collaborate">

&nbsp;       <div class="content">

&nbsp;         <h1>Samarbeid med oss</h1>

&nbsp;         <p>ARTEX er et åpent forskningsprosjekt. Har du ekspertise i arameisk, filologi, programmering eller kjønnsstudier? Vi vil gjerne høre fra deg!</p>

&nbsp;         <h2>Hvordan bidra</h2>

&nbsp;         <ul>

&nbsp;           <li>Delta i oversettelsesarbeid</li>

&nbsp;           <li>Bidra til vår kodebase</li>

&nbsp;           <li>Gi tilbakemeldinger på tekstene</li>

&nbsp;           <li>Del arameiske manuskripter</li>

&nbsp;         </ul>

&nbsp;         <h2>Kontakt</h2>

&nbsp;         <p>Send en e-post til <a href="mailto:kontakt@artex-prosjekt.no">kontakt@artex-prosjekt.no</a> eller besøk vår GitHub-side.</p>

&nbsp;         <h2>Finansiering</h2>

&nbsp;         <p>ARTEX støttes av Norges forskningsråd (2023/45678) og samarbeider med ledende institusjoner. Alle resultater publiseres under CC BY 4.0.</p>

&nbsp;       </div>

&nbsp;     </section>



&nbsp;     <footer>

&nbsp;       <div class="content">

&nbsp;         <p>\&copy; 2023-2025 ARTEX-prosjektet. All kode er lisensiert under MIT.</p>

&nbsp;       </div>

&nbsp;     </footer>

&nbsp;   </main>

&nbsp;   <script>

&nbsp;     document.addEventListener('DOMContentLoaded', function() {

&nbsp;       // Get all sections

&nbsp;       const sections = document.querySelectorAll('section');

&nbsp;       const navLinks = document.querySelectorAll('.page-nav a');

&nbsp;       

&nbsp;       // Function to update active navigation dot

&nbsp;       function updateActiveNav() {

&nbsp;         let current = '';

&nbsp;         

&nbsp;         sections.forEach(section => {

&nbsp;           const sectionTop = section.offsetTop;

&nbsp;           const sectionHeight = section.clientHeight;

&nbsp;           if (window.pageYOffset >= (sectionTop - sectionHeight / 3)) {

&nbsp;             current = section.getAttribute('id');

&nbsp;           }

&nbsp;         });

&nbsp;         

&nbsp;         navLinks.forEach(link => {

&nbsp;           link.classList.remove('active');

&nbsp;           if (link.getAttribute('href').substring(1) === current) {

&nbsp;             link.classList.add('active');

&nbsp;           }

&nbsp;         });

&nbsp;       }

&nbsp;       

&nbsp;       // Add smooth scrolling to nav links

&nbsp;       navLinks.forEach(link => {

&nbsp;         link.addEventListener('click', function(e) {

&nbsp;           e.preventDefault();

&nbsp;           

&nbsp;           const targetId = this.getAttribute('href');

&nbsp;           const targetSection = document.querySelector(targetId);

&nbsp;           

&nbsp;           window.scrollTo({

&nbsp;             top: targetSection.offsetTop,

&nbsp;             behavior: 'smooth'

&nbsp;           });

&nbsp;         });

&nbsp;       });

&nbsp;       

&nbsp;       // Update active nav on scroll

&nbsp;       window.addEventListener('scroll', updateActiveNav);

&nbsp;       

&nbsp;       // Initialize active nav

&nbsp;       updateActiveNav();

&nbsp;     });

&nbsp;   </script>

&nbsp; </body>

</html>

