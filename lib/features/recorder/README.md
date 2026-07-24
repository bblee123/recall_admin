# Recorder 录音模块 — 配置参数与功能说明

面向桌面端（macOS / Windows）的短录音模块，典型场景：**单词 / 词条录音**（录制 → 试听 → 保存）。

业务侧通常只调用 `showRecorderDialog`；本文档列出全部配置参数、功能行为与落盘规则。

---

## 1. 目录结构

```
lib/features/recorder/
├── recorder_dialog.dart              # 入口 showRecorderDialog + Dialog
├── recorder_test_page.dart           # 测试页
├── cubit/
│   ├── recorder_cubit.dart           # 会话逻辑
│   └── recorder_state.dart           # 状态（freezed）
├── service/
│   ├── audio_recorder_service.dart   # record 采集（写临时文件）
│   ├── recorder_options.dart         # 录音配置
│   ├── recorder_player_service.dart  # 试听（flutter_soloud）
│   └── recorder_sink.dart            # 临时文件 → 最终位置
└── widgets/
    ├── recorder_panel.dart           # 主面板
    ├── recorder_settings.dart        # 设置区
    └── waveform_view.dart            # 波形
```

---

## 2. 功能一览

| 功能 | 说明 |
|------|------|
| 弹窗录音 | `showRecorderDialog`，模态、不可点遮罩关闭 |
| 空格切换 | 聚焦面板时，空格 = 开始 / 结束 |
| 实时时长 | `MM:SS.d` 格式计时 |
| 实时波形 | 振幅流归一化后绘制；静音下限 -50 dBFS |
| 试听预览 | 停止后可播放 / 暂停 / 停止；播的是临时文件（未保存） |
| 可折叠设置 | 采样率、编码、声道、输入设备、保存目录、AGC / 回声消除 / 降噪 |
| 录音中锁定设置 | `recording` 时设置区禁用，避免中途改参 |
| 重置 | 取消当前录音（含未保存临时文件），回到空闲 |
| 保存转存 | 临时文件 → Sink 目标目录；同名自动 `_1`、`_2`… |
| 设备枚举 | 列出输入设备；可刷新（插拔后） |
| 实际采样率回报 | 硬件若调整请求采样率，UI 显示「实际采样率」 |
| 权限检查 | 开始前检查 / 请求麦克风权限 |

会话状态流转：

```
idle → recording → stopped → saved
         ↑            │
         └──── reset ─┘（回到 idle）
```

---

## 3. 入口 API：`showRecorderDialog`

```dart
Future<String?> showRecorderDialog(
  BuildContext context, {
  String? suggestName,
  RecorderOptions? defaults,
})
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `context` | `BuildContext` | 是 | 需能 `read` 到 `AudioRecorderService`；可选读到 `RecorderPlayerService`、`RecorderSink` |
| `suggestName` | `String?` | 否 | ① 弹窗标题：`录音 · {suggestName}`；② sanitize 后写入 `fileNamePrefix`；③ 保存时作为 `preferredName`（文件名） |
| `defaults` | `RecorderOptions?` | 否 | 本次弹窗的初始配置；未传则用 `RecorderOptions()` 默认值 |

**返回值**

| 值 | 含义 |
|----|------|
| `String` | 保存成功后的最终路径（本地路径；将来云端可为 URL/key） |
| `null` | 用户点关闭 / 取消，或未保存就退出 |

**`suggestName` 清洗规则**（`_sanitize`）

- 将 `\ / : * ? " < > |` 以及空白替换为 `_`
- 例：`hello world` → `hello_world`

**依赖注入（从 context 读取）**

| Provider | 必需 | 缺失时行为 |
|----------|------|------------|
| `AudioRecorderService` | 是 | 抛错，无法打开 |
| `RecorderPlayerService` | 否 | 无试听能力 |
| `RecorderSink` | 否 | 保存时用 `LocalFileSink`；若同时无 `outputDir` 则落到文档目录 `recordings/` |

---

## 4. 配置参数：`RecorderOptions`

定义文件：`service/recorder_options.dart`。不可变；通过 `copyWith` 更新。录音中不允许改（Cubit 直接忽略）。

### 4.1 字段一览

| 字段 | 类型 | 默认值 | 作用时机 | 说明 |
|------|------|--------|----------|------|
| `sampleRate` | `SampleRateTier` | `rate48k`（48000） | 开始录音 | 请求采样率；硬件不支持时可能被改写，见 `effectiveSampleRate` |
| `codec` | `RecorderCodec` | `wav` | 开始录音 | 编码器与文件扩展名 |
| `numChannels` | `int` | `1` | 开始录音 | `1` 单声道 / `2` 立体声；单词录音建议 1 |
| `bitRate` | `int` | `256000`（bps） | 开始录音 | **仅有损编码**（`aacLc`）生效；WAV/FLAC/PCM 忽略 |
| `deviceId` | `String?` | `null` | 开始录音 | 输入设备 id；`null` = 系统默认 |
| `deviceLabel` | `String?` | `null` | 仅展示 | 设备显示名；与 `deviceId` 成对 |
| `autoGain` | `bool` | `false` | 开始录音 | 自动增益（AGC） |
| `echoCancel` | `bool` | `false` | 开始录音 | 回声消除 |
| `noiseSuppress` | `bool` | `false` | 开始录音 | 降噪 |
| `outputDir` | `String?` | `null` | **保存时** | 显式本地目录；非空时优先于此落盘（覆盖注入 Sink 的默认目录） |
| `fileNamePrefix` | `String` | `'rec'` | 开始录音（临时文件名） | 临时文件：`{prefix}_{timestamp}.{ext}`；弹窗传入 `suggestName` 时会被覆盖为清洗后的名字 |

### 4.2 `copyWith` 特殊行为

| 参数 | 说明 |
|------|------|
| 常规字段 | `null` 表示保持原值 |
| `clearDevice: true` | 清空 `deviceId` / `deviceLabel`（回到系统默认设备） |

### 4.3 采样率：`SampleRateTier`

| 枚举 | Hz | UI 文案 | 建议场景 |
|------|-----|---------|----------|
| `rate16k` | 16000 | 16 kHz · 语音 | 语音识别 / 带宽敏感 |
| `rate22k` | 22050 | 22.05 kHz | 一般语音 |
| `rate44k` | 44100 | 44.1 kHz · CD | 音乐向 / CD 标准 |
| `rate48k` | 48000 | 48 kHz · 录音棚 | **默认**；清晰度优先 |
| `rate96k` | 96000 | 96 kHz · 高解析 | 需设备支持；文件更大 |

`SampleRateTier.fromHz(int)`：匹配不到时回退 `rate48k`。

> 请求值 ≠ 实际值时，设置区会显示「实际采样率：xxxx Hz」。

### 4.4 编码：`RecorderCodec`

| 枚举 | 底层 encoder | 扩展名 | UI 文案 | 有损 | 备注 |
|------|--------------|--------|---------|------|------|
| `wav` | `AudioEncoder.wav` | `.wav` | WAV · 无损 | 否 | **默认**；适合标准素材 |
| `pcm16` | `AudioEncoder.pcm16bits` | `.pcm` | PCM 16bit · 裸流 | 否 | 无容器头，后续处理需自知格式 |
| `flac` | `AudioEncoder.flac` | `.flac` | FLAC · 无损压缩 | 否 | 体积小于 WAV |
| `aacLc` | `AudioEncoder.aacLc` | `.m4a` | AAC-LC · 有损 | 是 | 依赖 `bitRate` |

`isLossy`：仅 `aacLc` 为 `true`。

### 4.5 代码配置示例

**弹窗级（本次有效，且 `outputDir` 优先生效）：**

```dart
await showRecorderDialog(
  context,
  suggestName: word.text,
  defaults: const RecorderOptions(
    sampleRate: SampleRateTier.rate16k,
    codec: RecorderCodec.wav,
    numChannels: 1,
    autoGain: false,
    echoCancel: false,
    noiseSuppress: false,
    outputDir: '/Volumes/Data/word_audio',
  ),
);
```

**全局默认落盘目录（无 `outputDir` 时的兜底）：**

```dart
// lib/core/di.dart
final recorderSink = LocalFileSink(
  directory: '/Volumes/Data/recordings',
);
```

**UI 内修改**：设置面板调用 `cubit.updateOptions(opts.copyWith(...))`，录音中无效。

---

## 5. 保存路径与文件命名

### 5.1 两阶段写盘

1. **录音中**：写入系统临时目录  
   `{TemporaryDirectory}/{fileNamePrefix}_{timestamp}.{ext}`
2. **点保存**：经 Sink `copy` 到最终目录，返回最终路径；弹窗 `pop(path)`

### 5.2 最终目录优先级（高 → 低）

| 优先级 | 来源 | 条件 |
|--------|------|------|
| 1 | `state.options.outputDir` | 非 null 且非空（含 UI 选择、`defaults.outputDir`）→ 使用 `LocalFileSink(directory: outputDir)` |
| 2 | 注入的 `RecorderSink` | 未设 `outputDir` 时使用（`di.dart` 中当前为 `LocalFileSink()`） |
| 3 | 兜底 `LocalFileSink` | 无注入 Sink 时；`directory == null` → `{ApplicationDocumentsDirectory}/recordings` |

### 5.3 最终文件名

| 条件 | 文件名 |
|------|--------|
| 有 `preferredName`（来自 `suggestName`） | `{preferredName}{ext}`；若已自带相同扩展名则不重复追加 |
| 无 `preferredName` | 沿用临时文件 basename |

同名已存在：`name.ext` → `name_1.ext` → `name_2.ext` …

目标目录不存在时会 `create(recursive: true)`。

---

## 6. Sink：`RecorderSink` / `LocalFileSink`

```dart
abstract class RecorderSink {
  Future<String> save(File tempFile, {String? preferredName});
}

class LocalFileSink implements RecorderSink {
  const LocalFileSink({this.directory});
  final String? directory; // null → 文档目录/recordings
}
```

| 参数 / 方法 | 说明 |
|-------------|------|
| `directory` | 本地目标目录；`null` 用默认 `recordings` |
| `save(tempFile, preferredName:)` | 复制临时文件到目标；返回最终绝对路径 |

扩展云端：实现 `RecorderSink`（如 `R2Sink`），在 `di.dart` 替换注入即可。注意：一旦用户设置了 `outputDir`，保存会强制走本地 `LocalFileSink(directory: outputDir)`，不再走注入的云端 Sink。

---

## 7. Cubit：`RecorderCubit`

### 7.1 构造参数

| 参数 | 类型 | 默认 | 说明 |
|------|------|------|------|
| `service` | `AudioRecorderService` | — | 必需 |
| `sink` | `RecorderSink?` | `null` | 注入的转存目标；见路径优先级 |
| `player` | `RecorderPlayerService?` | `null` | 无则无试听 |
| `initialOptions` | `RecorderOptions` | `RecorderOptions()` | 初始配置 |
| `amplitudeInterval` | `Duration` | `100ms` | 波形采样间隔 |
| `maxAmplitudeSamples` | `int` | `240` | 波形历史最大点数（约 24s @100ms） |

振幅归一化：dBFS ∈ `[-50, 0]` → `[0, 1]`；低于 -50 视为 0。

### 7.2 公开方法

| 方法 | 说明 |
|------|------|
| `init()` | 权限、设备列表、状态/振幅监听、采样率回调 |
| `refreshDevices()` | 重新枚举输入设备 |
| `toggle()` | 录音中 → `stop`；否则 → `start` |
| `start()` | 开始录音；无权限则再请求；会清掉上一段未保存预览 |
| `stop()` | 停止，进入 `stopped` |
| `reset()` | 取消录音 / 清空状态，回 `idle` |
| `save({preferredName})` | 转存；成功 → `saved` 并返回路径 |
| `updateOptions(options)` | 非录音中更新配置 |
| `playPreview()` / `pausePreview()` / `stopPreview()` | 试听控制 |

### 7.3 `RecorderState` 主要字段

| 字段 | 说明 |
|------|------|
| `status` | `idle` / `recording` / `stopped` / `saved` |
| `options` | 当前 `RecorderOptions` |
| `devices` | 可用输入设备列表 |
| `elapsed` | 已录时长 |
| `amplitudes` | 波形序列 `0..1` |
| `effectiveSampleRate` | 硬件实际采样率 |
| `tempPath` | 临时文件路径 |
| `savedPath` | 最终路径 |
| `hasPermission` | 麦克风权限；`null` = 未检查 |
| `busy` | 保存中等 |
| `playback` / `playbackPosition` / `playbackDuration` | 试听状态 |
| `error` | 错误文案 |

派生：`isRecording` / `canSave` / `canReset` / `hasPreview` / `isPlaying` / `isPaused`。

---

## 8. UI 组件参数

### 8.1 `RecorderPanel`

| 参数 | 类型 | 默认 | 说明 |
|------|------|------|------|
| `onSaved` | `ValueChanged<String>?` | `null` | 保存成功回调（Dialog 内用于 `pop(path)`） |
| `preferredName` | `String?` | `null` | 传给 `cubit.save` |
| `autofocus` | `bool` | `true` | 自动聚焦以接收空格 |

### 8.2 `RecorderSettings`

无构造参数；读写当前 `RecorderCubit`。提供：

- 采样率 / 编码 / 声道 / 输入设备下拉
- 刷新设备按钮
- 保存目录选择（`FilePicker.getDirectoryPath`）
- 自动增益 / 回声消除 / 降噪开关
- 实际采样率提示（有回报时）

### 8.3 `RecorderDialog`

| 参数 | 说明 |
|------|------|
| `title` | 标题文案 |
| `preferredName` | 传给面板，用于保存文件名 |

一般不直接构造，请用 `showRecorderDialog`。

---

## 9. 底层服务（简要）

### `AudioRecorderService`

封装 `record` 的 `AudioRecorder`：权限、设备列表、编码器探测、状态流、振幅流、`start/stop/pause/resume/cancel`。  
`start(options)` 按 `RecorderOptions` 建 `RecordConfig` 并写临时路径。

### `RecorderPlayerService`

基于 `flutter_soloud`（与 `MyencAudioService` 共用引擎）：`load` / `play` / `pause` / `resume` / `stop`、进度与时长查询。

---

## 10. 接入检查清单

1. `di.dart` 创建并注入 `AudioRecorderService`、`RecorderPlayerService`、`RecorderSink`
2. 平台已声明麦克风权限（macOS / Windows）
3. 业务调用 `showRecorderDialog(context, suggestName: ..., defaults: ...)`
4. 按返回的 `path` 做后续绑定（词条音轨、上传等）
5. 需要统一默认目录 → 配 `LocalFileSink(directory: ...)`；需要单次覆盖 → 配 `defaults.outputDir` 或 UI 选择

测试入口：`RecorderTestPage`。
