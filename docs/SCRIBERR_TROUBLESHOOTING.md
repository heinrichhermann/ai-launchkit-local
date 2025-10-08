# Scriberr Troubleshooting & Configuration Guide

This guide covers known issues and workarounds for Scriberr audio transcription service in AI LaunchKit.

## 🎯 Overview

Scriberr is an AI-powered audio transcription tool with features for:
- Automatic transcription with Whisper
- Speaker diarization
- Chat with transcripts using LLMs
- Summarization
- YouTube video transcription

## ⚙️ Automatic Fixes Applied

The following fixes are **automatically applied** by AI LaunchKit:

### ✅ GPU Support (Automatic)
- Scriberr GPU variant activates with `gpu-nvidia` profile
- Uses correct CUDA image: `v1.0.4-cuda`
- GPU passthrough with `count: all` (uses all available GPUs)
- Both CPUs available for multi-GPU systems

### ✅ YouTube Transcription (Automatic)
- Node.js automatically installed at startup
- yt-dlp automatically installed/upgraded
- Fixes Scriberr Issue #224
- No manual intervention needed

### ✅ Ollama Context Optimization (Automatic)
- OLLAMA_CONTEXT_LENGTH set to 65536
- Prevents transcript truncation
- Reduces hallucinations
- Optimal for dual-GPU setups

## ⚠️ Known Issues & Workarounds

### Issue 1: GPU Transcription cuDNN Error

**Problem:**
```
Unable to load libcudnn_cnn.so.9.1.0
RuntimeError: CUDA driver version insufficient
```

**Cause:** Library path issue in Scriberr v1.0.4-cuda image

**Workaround:** Use CPU profile instead
1. In Scriberr UI: Settings → Profiles
2. Create profile with Device: **CPU** (not cuda)
3. CPU transcription works reliably

**Status:** Upstream issue, waiting for Scriberr image update

---

### Issue 2: Chat Hallucinations / Wrong Answers

**Problem:** LLM invents content not in transcript

**Causes:**
1. **Context window too small** - Transcript gets truncated
2. **Model too small** - Can't handle long content
3. **Chat history accumulation** - Old messages add up

**Solutions:**

**✅ Already Fixed:**
- OLLAMA_CONTEXT_LENGTH increased to 65536
- Fits ~3 hour transcripts

**User Action Required:**
1. **Use larger model:**
   - ❌ llama3.2:3b (too small)
   - ✅ gemma3:8b/12b/27b (recommended)
   - ✅ qwen2.5:7b-instruct (good)

2. **Start fresh chat periodically:**
   - After ~20 questions, chat history fills context
   - Delete old chat, start new one
   - Prevents context overflow

3. **Use Ollama Cloud (free):**
   ```bash
   docker exec ollama ollama signin
   docker exec ollama ollama pull gpt-oss:120b-cloud
   ```
   - No context limits
   - Faster responses
   - Free during beta

**Token estimates:**
- 10-min audio: ~2,000 tokens
- 90-min audio: ~21,000 tokens
- Chat message: ~500 tokens
- After 20 turns: ~30,000 tokens

---

### Issue 3: Chat Timeout Errors

**Problem:**
```
Error: Client.Timeout exceeded while awaiting headers
```

**Cause:** Scriberr timeout set to 30 seconds (too short for long transcripts)

**Status:** Known bug (Issue #237), will be fixed in next Scriberr release

**Workarounds:**
1. **Use Summarize instead of Chat**
   - Works for long transcripts
   - No timeout issues

2. **Use Ollama Cloud models**
   - Much faster (cloud GPUs)
   - No timeouts

3. **Ask shorter questions**
   - Specific questions vs. "summarize everything"
   - Usually completes within 30 seconds

---

### Issue 4: YouTube Download Fails

**Problem:**
```
Failed to download YouTube audio: exit status 1
```

**Cause:** YouTube requires JavaScript runtime (Issue #224)

**Solution:** ✅ **Automatically fixed by AI LaunchKit**
- Node.js installed at startup
- yt-dlp installed/upgraded at startup
- Should work out of the box

**Manual verification:**
```bash
# Check if Node.js installed:
docker exec localai-scriberr-gpu-1 node --version

# Check if yt-dlp installed:
docker exec localai-scriberr-gpu-1 yt-dlp --version
```

**If still fails:** Wait for Scriberr image update with permanent fix

---

## 🚀 Best Practices

### For GPU Users (Recommended)

**Profile Configuration:**
- **Don't set device to "cuda"** in Scriberr UI
- Use default (CPU) for now
- Transcription still benefits from GPU passthrough
- Avoids cuDNN errors

### For Chat Feature

**Model Selection:**
- Minimum: gemma3:8b (for quality)
- Recommended: gemma3:27b (best for long transcripts)
- Alternative: gpt-oss:120b-cloud (free, no limits)

**Chat Management:**
- Start new chat after 15-20 questions
- Keeps context window clean
- Prevents overflow and hallucinations

### For Long Transcripts (90+ minutes)

**Recommendations:**
1. Use **Summarize** feature (not Chat)
2. If using Chat: Ask specific questions
3. Consider Ollama Cloud models for speed
4. Verify transcript length: https://llmtokencounter.com

---

## 🔧 Advanced Configuration

### Increase Ollama Context (Already Done)

Current setting: `OLLAMA_CONTEXT_LENGTH=65536`

For even longer transcripts:
```yaml
# In docker-compose.local.yml:
OLLAMA_CONTEXT_LENGTH=131072  # 2x current (needs ~50GB VRAM)
```

Only needed for 6+ hour transcripts.

### GPU Memory Monitoring

```bash
# Watch GPU usage during transcription:
watch -n 1 nvidia-smi

# Check Ollama logs for context info:
docker logs ollama | grep "KvSize"
```

---

## 📚 Related Resources

- [Scriberr GitHub](https://github.com/rishikanthc/Scriberr)
- [Issue #224: YouTube downloads fail](https://github.com/rishikanthc/Scriberr/issues/224)
- [Issue #237: Chat timeout errors](https://github.com/rishikanthc/Scriberr/issues/237)
- [Scriberr Documentation](https://scriberr.app/docs/intro.html)

---

## 🆘 Getting Help

If you encounter issues:
1. Check Scriberr logs: `docker logs localai-scriberr-gpu-1`
2. Check Ollama logs: `docker logs ollama`
3. Verify GPU access: `docker exec localai-scriberr-gpu-1 nvidia-smi`
4. Report issues on [AI LaunchKit GitHub](https://github.com/hermannheinrich/ai-launchkit-local/issues)
