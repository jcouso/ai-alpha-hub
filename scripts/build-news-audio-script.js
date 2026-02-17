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

const clean = (s) => s
  .replace(/\*\*/g, '')
  .replace(/\*/g, '')
  .replace(/`/g, '')
  .replace(/\[([^\]]+)\]\([^\)]+\)/g, '$1')
  .replace(/[🔥⚠️📄🛡️🎬🚀🤖🎙️📺🧑‍💻⚙️🎯📊🚫🧭]/g, '')
  .replace(/\s+/g, ' ')
  .trim();

function getSection(title) {
  const esc = title.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  const regex = new RegExp(`##\\s+${esc}[\\s\\S]*?(?=\\n##\\s+|\\n?$)`);
  const m = md.match(regex);
  return m ? m[0] : '';
}

function getBullets(section, max = 4) {
  return section
    .split('\n')
    .map(l => l.trim())
    .filter(l => l.startsWith('- '))
    .map(l => clean(l.replace(/^-\s+/, '')))
    .filter(Boolean)
    .slice(0, max);
}

function getTopMoves(max = 3) {
  const sec = getSection('🚀 Top Early Moves');
  const matches = [...sec.matchAll(/^###\s+(.+)$/gm)].map(m => clean(m[1]).replace(/^\d+\.\s*/, ''));
  return matches.slice(0, max);
}

const tldr = getBullets(getSection('TL;DR'), 4);
const moves = getTopMoves(3);
const actions = getSection('🎯 Action Pack')
  .split('\n')
  .map(l => l.trim())
  .filter(l => /^\d+\.\s+/.test(l))
  .map(l => clean(l.replace(/^\d+\.\s+/, '')))
  .slice(0, 2);

const spokenDate = new Date(`${dateArg}T12:00:00Z`).toLocaleDateString('en-US', {
  month: 'long',
  day: 'numeric',
  year: 'numeric'
});

const lines = [];
lines.push(`AI Alpha audio briefing for ${spokenDate}.`);
lines.push(`Here are today's key signals in under three minutes.`);

if (tldr.length) {
  lines.push('Top headlines:');
  tldr.forEach((b, i) => lines.push(`${i + 1}. ${b}`));
}

if (moves.length) {
  lines.push('Most actionable moves:');
  moves.forEach((m, i) => lines.push(`${i + 1}. ${m}`));
}

if (actions.length) {
  lines.push('Next actions for today:');
  actions.forEach((a, i) => lines.push(`${i + 1}. ${a}`));
}

lines.push('Full links and source details are available in the written report.');
lines.push('End of briefing.');

const scriptText = lines.join('\n\n');
fs.mkdirSync(path.dirname(outPath), { recursive: true });
fs.writeFileSync(outPath, scriptText + '\n', 'utf8');

console.log(outPath);
