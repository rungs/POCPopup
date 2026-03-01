<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Relay.aspx.cs" Inherits="POCPopup.Relay" %>

    <!DOCTYPE html>
    <html xmlns="http://www.w3.org/1999/xhtml">

    <head runat="server">
        <title>กำลังเปิดข้อมูล...</title>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <style>
            * {
                box-sizing: border-box;
                margin: 0;
                padding: 0;
            }

            body {
                font-family: 'Segoe UI', Arial, sans-serif;
                min-height: 100vh;
                background: linear-gradient(135deg, #1a1a2e 0%, #16213e 60%, #0f3460 100%);
                display: flex;
                align-items: center;
                justify-content: center;
                color: #fff;
            }

            .card {
                background: rgba(255, 255, 255, 0.07);
                backdrop-filter: blur(12px);
                border: 1px solid rgba(255, 255, 255, 0.12);
                border-radius: 20px;
                padding: 44px 52px;
                max-width: 480px;
                width: 92%;
                text-align: center;
                box-shadow: 0 24px 64px rgba(0, 0, 0, 0.5);
            }

            .icon {
                font-size: 52px;
                margin-bottom: 18px;
            }

            h1 {
                font-size: 22px;
                font-weight: 700;
                margin-bottom: 8px;
            }

            .url-label {
                font-size: 12px;
                color: rgba(255, 255, 255, 0.45);
                margin-bottom: 4px;
                text-transform: uppercase;
                letter-spacing: .05em;
            }

            .url-text {
                background: rgba(99, 179, 237, 0.12);
                border: 1px solid rgba(99, 179, 237, 0.3);
                color: #90cdf4;
                border-radius: 8px;
                padding: 8px 14px;
                font-size: 13px;
                word-break: break-all;
                margin-bottom: 28px;
            }

            /* ─── Step indicator ─── */
            .steps {
                display: flex;
                gap: 0;
                margin-bottom: 28px;
            }

            .step {
                flex: 1;
                padding: 10px 6px;
                font-size: 12px;
                border-top: 3px solid rgba(255, 255, 255, 0.15);
                color: rgba(255, 255, 255, 0.4);
            }

            .step.active {
                border-color: #68d391;
                color: #68d391;
                font-weight: 600;
            }

            .step.done {
                border-color: rgba(104, 211, 145, 0.4);
                color: rgba(104, 211, 145, 0.6);
            }

            /* ─── Message box ─── */
            .msg-box {
                padding: 14px 18px;
                border-radius: 10px;
                font-size: 14px;
                line-height: 1.6;
                margin-bottom: 20px;
            }

            .msg-info {
                background: rgba(99, 179, 237, 0.12);
                border: 1px solid rgba(99, 179, 237, 0.3);
                color: #90cdf4;
            }

            .msg-success {
                background: rgba(104, 211, 145, 0.12);
                border: 1px solid rgba(104, 211, 145, 0.3);
                color: #68d391;
            }

            .msg-warn {
                background: rgba(246, 173, 85, 0.12);
                border: 1px solid rgba(246, 173, 85, 0.3);
                color: #f6ad55;
            }

            /* ─── Buttons ─── */
            .btn-reopen {
                background: rgba(255, 255, 255, 0.1);
                border: 1px solid rgba(255, 255, 255, 0.25);
                color: #fff;
                border-radius: 8px;
                padding: 10px 24px;
                font-size: 14px;
                cursor: pointer;
                transition: background .2s;
                margin-top: 4px;
            }

            .btn-reopen:hover {
                background: rgba(255, 255, 255, 0.2);
            }

            .footer-hint {
                margin-top: 24px;
                padding-top: 16px;
                border-top: 1px solid rgba(255, 255, 255, 0.08);
                font-size: 12px;
                color: rgba(255, 255, 255, 0.35);
            }

            .footer-hint strong {
                color: rgba(255, 255, 255, 0.6);
            }

            /* pulse dot */
            .dot {
                display: inline-block;
                width: 8px;
                height: 8px;
                background: #68d391;
                border-radius: 50%;
                margin-right: 6px;
                vertical-align: middle;
                animation: pulse 2s infinite;
            }

            @keyframes pulse {

                0%,
                100% {
                    opacity: 1
                }

                50% {
                    opacity: .25
                }
            }
        </style>
    </head>

    <body>
        <div class="card">
            <div class="icon" id="cardIcon">📄</div>
            <h1>หน้าข้อมูลภายนอก</h1>

            <div class="url-label">URL ปลายทาง</div>
            <div class="url-text" id="urlDisplay">กำลังโหลด...</div>

            <!-- Step indicator -->
            <div class="steps">
                <div class="step done" id="step1">1. เปิด Relay</div>
                <div class="step active" id="step2">2. เปิดข้อมูล</div>
                <div class="step" id="step3">3. ดูเสร็จแล้ว</div>
            </div>

            <!-- Status message (dynamic) -->
            <div id="msgBox" class="msg-box msg-info">
                ⏳ กำลังเปิดหน้าข้อมูล...
            </div>

            <button id="btnReopen" class="btn-reopen" style="display:none;" onclick="openExternal()">
                &#x21BA; เปิดอีกครั้ง
            </button>

            <div class="footer-hint">
                <span class="dot"></span>
                <strong>ปิด Tab นี้</strong> เมื่อดูข้อมูลเสร็จแล้ว
                — หน้าต้นทางจะรับรู้โดยอัตโนมัติ
            </div>
        </div>

        <script type="text/javascript">
            var targetUrl = '';
            var extWin = null;

            // ─── อ่าน URL จาก query string ───────────────────────────
            (function () {
                var p = new URLSearchParams(window.location.search);
                targetUrl = p.get('url') || '';
                document.getElementById('urlDisplay').textContent = targetUrl || '(ไม่ระบุ URL)';
                document.title = 'ข้อมูล: ' + targetUrl;
            })();

            // ─── Auto-open เมื่อหน้าโหลดเสร็จ ────────────────────────
            window.addEventListener('load', function () {
                setTimeout(openExternal, 500); // รอ 0.5 วิ ให้ browser พร้อม
            });

            function openExternal() {
                if (!targetUrl) {
                    setMsg('warn', '⚠️ ไม่มี URL ปลายทาง');
                    return;
                }

                extWin = window.open(
                    targetUrl,
                    'infoPopup',
                    'width=1280,height=800,left=40,top=40,resizable=yes,scrollbars=yes'
                );

                if (!extWin) {
                    // popup ถูก block → เปิดใน tab แทน
                    extWin = window.open(targetUrl, '_blank');
                }

                if (extWin) {
                    setStep(2, 3);
                    setMsg('success',
                        '✅ หน้าข้อมูลเปิดแล้ว<br>' +
                        '<span style="font-size:12px;opacity:.7;">กลับมาที่ Tab นี้แล้วปิด เมื่อดูเสร็จ</span>');
                    document.getElementById('btnReopen').style.display = 'inline-block';

                    // monitor popup: ถ้าผู้ใช้ปิด popup → เปลี่ยน message แต่ไม่ปิด relay
                    var checkExt = setInterval(function () {
                        try {
                            if (extWin && extWin.closed) {
                                clearInterval(checkExt);
                                setMsg('warn', '⚠️ หน้าข้อมูลถูกปิดแล้ว<br><small>คลิก "เปิดอีกครั้ง" หากต้องการ หรือ<strong>ปิด Tab นี้</strong>เมื่อเสร็จ</small>');
                            }
                        } catch (e) { clearInterval(checkExt); }
                    }, 600);

                } else {
                    setMsg('warn', '⚠️ ไม่สามารถเปิดหน้าข้อมูลได้ — กรุณาอนุญาต popup');
                }
            }

            // ─── แจ้ง opener เมื่อ Relay Tab กำลังปิด ────────────────
            window.addEventListener('beforeunload', function () {
                if (window.opener && !window.opener.closed) {
                    try {
                        window.opener.postMessage({ type: 'RELAY_CLOSING' }, window.location.origin);
                    } catch (e) { }
                }
            });

            // ─── Helpers ──────────────────────────────────────────────
            function setStep(doneUpto, activeIdx) {
                [1, 2, 3].forEach(function (i) {
                    var el = document.getElementById('step' + i);
                    el.className = 'step' + (i < activeIdx ? ' done' : i === activeIdx ? ' active' : '');
                });
            }

            function setMsg(type, html) {
                var el = document.getElementById('msgBox');
                el.className = 'msg-box msg-' + type;
                el.innerHTML = html;
            }
        </script>
    </body>

    </html>