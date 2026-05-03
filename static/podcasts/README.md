# 播客音频文件说明

## 支持的音频格式

- **MP3** - 最常用的格式，兼容性最好
- **WAV** - 无损格式，文件较大
- **M4A** - Apple 格式，高质量
- **OGG** - 开源格式，质量好

## 如何添加播客音频文件

1. 将音频文件放到此目录：`static/podcasts/`
2. 在播客 markdown 文件中引用：
   ```yaml
   ---
   title: "第002期：播客标题"
   audio_file: "/podcasts/002-episode.mp3"
   audio_format: "mp3"
   audio_size: "5.2 MB"
   duration: "10:30"
   ---
   ```

## 音频文件命名建议

- 使用序号开头：`001-`, `002-`, `003-`
- 使用英文名称，避免空格和特殊字符
- 示例：`001-welcome.mp3`, `002-tech-talk.mp3`

## 音频质量建议

- **MP3**: 128kbps 或 192kbps
- **采样率**: 44.1kHz 或 48kHz
- **声道**: 单声道（mono）可减小文件大小
- **比特率**: 语音推荐 64-128kbps

## 在线音频编辑工具

- **Audacity** (免费，开源) - https://www.audacityteam.org/
- **Adobe Podcast** (在线) - https://podcast.adobe.com/enhance
- **Descript** (在线) - https://www.descript.com/

## 音频文件压缩工具

- **FFmpeg** (命令行):
  ```bash
  ffmpeg -i input.wav -b:a 128k output.mp3
  ```
- **在线转换**:
  - https://cloudconvert.com/
  - https://online-audio-converter.com/

## 注意事项

- 音频文件会占用网站存储空间
- 建议单个文件不超过 50MB
- 定期检查和优化音频文件大小
- 考虑使用 CDN 加速音频文件传输
