// Run before deploying: node tool/check_media.mjs
// Uses the content paths as the source of truth, never substitute/demo media.
import { readFile, stat } from 'node:fs/promises';
import { resolve, sep } from 'node:path';

const profile = JSON.parse(await readFile('assets/data/profile.json', 'utf8'));
const { projects } = JSON.parse(await readFile('assets/data/projects.json', 'utf8'));
const root = resolve('web');
let total = 0;
let failures = 0;

async function check(owner, field, path) {
  if (!path) return;
  total++;
  const file = resolve(root, path);
  if (!file.startsWith(root + sep)) throw new Error(`Path outside web/: ${path}`);
  try {
    const info = await stat(file);
    if (!info.isFile() || info.size === 0) throw new Error('empty or not a file');
    if (path.endsWith('.mp4') && info.size > 50_000_000) {
      throw new Error('video must be at most 50 MB');
    }
  } catch (error) {
    console.error(`[${owner}] ${field}: web/${path} — ${error.code === 'ENOENT' ? 'missing' : error.message}`);
    failures++;
  }
}

await check('profile', 'photo', profile.photo);
await check('profile', 'resume', profile.resumePdf);
for (const project of projects) {
  await check(project.slug, 'cover', project.cover);
  for (const [i, screen] of (project.screens ?? []).entries()) {
    await check(project.slug, `screens[${i}].src`, screen.src);
  }
  const videos = project.videos ?? {};
  for (const [i, group] of (project.additionalVideos ?? []).entries()) {
    for (const [platform, video] of Object.entries(group)) {
      if (!['ios', 'android', 'web'].includes(platform)) {
        throw new Error(`${project.slug}: unknown additionalVideos[${i}].${platform}`);
      }
      await check(project.slug, `additionalVideos[${i}].${platform}.src`, video.src);
      await check(project.slug, `additionalVideos[${i}].${platform}.poster`, video.poster);
    }
  }
  if (Array.isArray(videos) || typeof videos !== 'object') {
    throw new Error(`${project.slug}: videos must be an object`);
  }
  for (const [platform, video] of Object.entries(videos)) {
    if (!['ios', 'android', 'web'].includes(platform)) {
      throw new Error(`${project.slug}: unknown videos.${platform}`);
    }
    await check(project.slug, `videos.${platform}.src`, video.src);
    await check(project.slug, `videos.${platform}.poster`, video.poster);
  }
}
console.log(`${total - failures}/${total} referenced media files ready.`);
process.exitCode = failures ? 1 : 0;
