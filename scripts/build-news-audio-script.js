#!/usr/bin/env node
const fs = require('fs');
const path = require('path');

const repoRoot = path.resolve(__dirname, '..');
const dateArg = process.argv[2] || new Date().toISOString().slice(0, 10);
const reportPath = path.join(repoRoot, 'docs', 'reports', `${dateArg}.md`);
const outPath = path.join(repoRoot, 'docs', 'audio', `${dateArg}-script.txt`);

if (!fs.existsSync(reportPath)) {
  console.error(`Report not found: ${reportPath}`);
  process.exit(1);
}

const md = fs.readFileSync(reportPath, 'utf8');

function toWords(n) {
  const small = [
    'zero','one','two','three','four','five','six','seven','eight','nine','ten',
    'eleven','twelve','thirteen','fourteen','fifteen','sixteen','seventeen','eighteen','nineteen','twenty'
  ];
  if (Number.isNaN(n)) return '';
  if (n >= 0 && n <= 20) return small[n];
  return String(n);
}

function cleanLine(s) {
  return s
    .replace(/\[([^\]]+)\]\([^\)]+\)/g, '$1')
    .replace(/[*`>#]/g, '')
    .replace(/[🔥⚠️📄🛡️🎬🚀🤖🎙️📺🧑‍💻⚙️🎯📊🚫🧭]/g, '')
    .replace(/AGENTS\.md/gi, 'AGENTS dot M D')
    .replace(/PRs\b/g, 'pull requests')
    .replace(/(\d+)\s*-\s*(\d+)x/gi, (_, a, b) => `${toWords(Number(a))} to ${toWords(Number(b))} times`)
    .replace(/\$(\d+)M\b/gi, (_, a) => `${toWords(Number(a))} million dollars`)
    .replace(/(\d+)B\b/gi, (_, a) => `${toWords(Number(a))} billion`)
    .replace(/(\d+)%/g, (_, a) => `${toWords(Number(a))} percent`)
    .replace(/\b(\d+)\b/g, (_, a) => toWords(Number(a)))
    .replace(/\s+/g, ' ')
    .trim();
}

function section(title) {
  const esc = title.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  const rgx = new RegExp(`##\\s+${esc}[\\s\\S]*?(?=\\n##\\s+|\\n?$)`);
  const m = md.match(rgx);
  return m ? m[0] : '';
}

function bullets(sec, max) {
  return sec
    .split('\n')
    .map(x => x.trim())
    .filter(x => x.startsWith('- '))
    .map(x => cleanLine(x.replace(/^-\s+/, '')))
    .filter(Boolean)
    .slice(0, max);
}

const tldr = bullets(section('TL;DR'), 5);
const actions = section('🎯 Action Pack')
  .split('\n')
  .map(x => x.trim())
  .filter(x => /^\d+\.\s+/.test(x))
  .map(x => cleanLine(x.replace(/^\d+\.\s+/, '')))
  .filter(Boolean)
  .slice(0, 3);

const dt = new Date(`${dateArg}T12:00:00Z`);
const spokenDate = dt.toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' });

const lines = [];
lines.push(`AI Alpha briefing for ${spokenDate}.`);
lines.push('Here is the short version of what actually matters today.');

const transitions = ['First', 'Second', 'Third', 'Fourth', 'And fifth'];
tldr.forEach((item, i) => {
  lines.push(`${transitions[i] || 'Next'}, ${item}.`);
});

if (actions.length) {
  lines.push('For today, run three actions.');
  actions.forEach((a, i) => {
    const lead = ['One', 'Two', 'Three'][i] || `Step ${i + 1}`;
    lines.push(`${lead}: ${a}.`);
  });
}

lines.push('Full links and deeper analysis are in the written report.');
lines.push('End of briefing.');

const out = lines.join('\n\n') + '\n';
fs.mkdirSync(path.dirname(outPath), { recursive: true });
fs.writeFileSync(outPath, out, 'utf8');

console.log(outPath);
