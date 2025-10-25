# Gotenberg - Document Conversion Service

> **TL;DR:** Gotenberg converts documents, web pages, and HTML to PDF using a simple HTTP API. Perfect for automated document generation in n8n workflows.

## 🎯 What is Gotenberg?

Gotenberg is a Docker-powered stateless API for converting:
- **HTML/CSS/JS** → PDF
- **Markdown** → PDF
- **Office Documents** (Word, Excel, PowerPoint) → PDF
- **Images** → PDF
- **Web Pages** (URL) → PDF

## 🚀 Quick Start

### Access

- **API Endpoint:** `http://SERVER_IP:8094`
- **Health Check:** `http://SERVER_IP:8094/health`
- **No UI** - API only service

### Example: Convert HTML to PDF

```bash
curl --request POST \
  --url http://SERVER_IP:8094/forms/chromium/convert/html \
  --form files=@document.html \
  --output result.pdf
```

### Example: Convert URL to PDF

```bash
curl --request POST \
  --url http://SERVER_IP:8094/forms/chromium/convert/url \
  --form url=https://example.com \
  --output webpage.pdf
```

## 🔌 Integration with n8n

### Use HTTP Request Node in n8n

**Convert HTML to PDF:**

```javascript
// HTTP Request Node Configuration
Method: POST
URL: http://gotenberg:3000/forms/chromium/convert/html
Body Content Type: Form-Data

// Add file or HTML content:
files: [your HTML content]

// Response options:
Binary Data: true
Download: true
```

## 📚 Official Documentation

**Complete API Reference:**
https://gotenberg.dev/docs/get-started/introduction

**Key Resources:**
- **Chromium Module:** https://gotenberg.dev/docs/modules/chromium
- **LibreOffice Module:** https://gotenberg.dev/docs/modules/libreoffice
- **PDF Engines:** https://gotenberg.dev/docs/modules/pdf-engines

## 🔧 Common Use Cases

1. **Generate Reports:** Convert HTML templates to PDFs
2. **Invoice Generation:** Create professional invoices from data
3. **Archive Web Pages:** Save web content as PDFs
4. **Document Conversion:** Convert Office docs to PDFs
5. **Receipt Generation:** Create printable receipts

## ⚡ Tips

- **Performance:** Gotenberg is stateless - scales horizontally
- **Format:** Returns binary PDF data
- **Headers:** Set appropriate Content-Type headers
- **Files:** Can accept multiple files in multipart/form-data

For detailed examples and advanced options, see the official Gotenberg documentation.
