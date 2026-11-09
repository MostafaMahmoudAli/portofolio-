// Run before deploying: node tool/check_media.mjs
// Uses the content paths as the source of truth, never substitute/demo media.
import { readFile, stat } from 'node:fs/promises';
import { resolve, sep } from 'node:path';

const profile = JSON.parse(await readFile('assets/data/profile.json', 'utf8'));
const { projects } = JSON.parse(await readFile('assets/data/projects.json', 'utf8'));
const paths = new Set([
  profile.photo,
  profile.resumePdf,
  ...projects.flatMap(project => [
    project.cover,
    ...project.videos.flatMap(video => [video.src, video.poster]),
  ]),
].filter(Boolean));
const root = resolve('web');
let failures = 0;
for (const path of paths) {
  const file = resolve(root, path);
  if (!file.startsWith(root + sep)) throw new Error(`Path outside web/: ${path}`);
  try {
    const info = await stat(file);
    if (!info.isFile() || info.size === 0) throw new Error('empty or not a file');
    if (path.endsWith('.mp4') && info.size >= 10_000_000) {
      throw new Error('video must be under 10 MB');
    }
  } catch (error) {
    console.error(`BLOCKED web/${path}: ${error.code === 'ENOENT' ? 'missing' : error.message}`);
    failures++;
  }
}
console.log(`${paths.size - failures}/${paths.size} referenced media files ready.`);
process.exitCode = failures ? 1 : 0;
