<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TestPage.aspx.cs" Inherits="POCPopup.TestPage" %>

    <!DOCTYPE html>
    <html xmlns="http://www.w3.org/1999/xhtml">

    <head runat="server">
        <title>Test External Page</title>
        <meta charset="utf-8" />
        <style>
            body {
                font-family: 'Segoe UI', Arial, sans-serif;
                display: flex;
                justify-content: center;
                align-items: center;
                min-height: 100vh;
                margin: 0;
                background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
                color: #fff;
            }

            .card {
                background: rgba(255, 255, 255, 0.1);
                backdrop-filter: blur(10px);
                border: 1px solid rgba(255, 255, 255, 0.2);
                border-radius: 16px;
                padding: 48px 56px;
                text-align: center;
                max-width: 480px;
            }

            .icon {
                font-size: 64px;
                margin-bottom: 16px;
            }

            h1 {
                margin: 0 0 12px;
                font-size: 28px;
            }

            p {
                color: rgba(255, 255, 255, 0.7);
                line-height: 1.6;
            }

            .badge {
                display: inline-block;
                background: rgba(74, 222, 128, 0.2);
                border: 1px solid rgba(74, 222, 128, 0.5);
                color: #4ade80;
                border-radius: 20px;
                padding: 4px 16px;
                font-size: 13px;
                margin-bottom: 24px;
            }

            .close-btn {
                display: inline-block;
                margin-top: 24px;
                padding: 12px 32px;
                background: rgba(255, 255, 255, 0.15);
                border: 1px solid rgba(255, 255, 255, 0.3);
                border-radius: 8px;
                color: #fff;
                cursor: pointer;
                font-size: 15px;
                transition: background 0.2s;
            }

            .close-btn:hover {
                background: rgba(255, 255, 255, 0.25);
            }
        </style>
    </head>

    <body>
        <div class="card">
            <div class="icon">🌐</div>
            <div class="badge">✅ Tab เปิดสำเร็จ</div>
            <h1>External Page (Test)</h1>
            <p>
                หน้านี้จำลองแทนหน้าภายนอก เช่น หน้าชำระเงิน, หน้าลงชื่อเข้าใช้, หรือหน้าบริการอื่นๆ
                <br /><br />
                <strong>ปิด Tab นี้</strong> เพื่อทดสอบว่า Default.aspx สามารถตรวจจับได้
            </p>
            <br />
            <button class="close-btn" onclick="window.close()">ปิด Tab นี้</button>
        </div>

        <script type="text/javascript">
            // แจ้ง parent ทันทีเมื่อ tab นี้กำลังจะปิด
            window.addEventListener('beforeunload', function () {
                if (window.opener && !window.opener.closed) {
                    try {
                        window.opener.postMessage({ type: 'CHILD_TAB_CLOSING' }, window.location.origin);
                    } catch (e) { }
                }
            });
        </script>
    </body>

    </html>