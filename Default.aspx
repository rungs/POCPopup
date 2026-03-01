<%@ Page Title="Home Page" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="Default.aspx.cs" Inherits="POCPopup._Default" %>

    <asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

        <main>
            <section class="row" aria-labelledby="aspnetTitle">
                <h1 id="aspnetTitle">ASP.NET</h1>
                <p class="lead">ASP.NET is a free web framework for building great Web sites and Web applications using
                    HTML, CSS, and JavaScript.</p>
            </section>

            <%--=====Open Info Tab Demo=====--%>
                <div class="row" style="margin-top:20px;">
                    <div class="col-md-12">
                        <hr />
                        <h2>Open Info Tab Demo</h2>
                        <p style="color:#555;">เปิดหน้าแสดงข้อมูล → รอให้ผู้ใช้ปิด Tab เอง → Default.aspx
                            รับรู้อัตโนมัติ</p>

                        <div class="input-group" style="max-width:520px; margin-bottom:12px;">
                            <input type="text" id="txtUrl" class="form-control" value="https://cedarqa.cedar.in.th/"
                                placeholder="URL หน้าข้อมูล (external)" />
                            <span class="input-group-btn">
                                <button id="btnOpenTab" class="btn btn-success btn-lg">
                                    &#x2197; ดูข้อมูล
                                </button>
                            </span>
                        </div>

                        <div id="tabStatus" style="max-width:520px; padding:12px 16px;
                                           border-radius:4px; display:none; font-weight:bold;"></div>
                    </div>
                </div>
        </main>

        <script type="text/javascript">
            // =============================================
            // State
            // =============================================
            var openedTab = null;   // window reference ของ tab
            var tabActive = false;  // กำลังรอ tab ปิดอยู่
            var pollTimer = null;
            var openedAt = 0;
            var isCOOP = false;

            var GRACE_MS = 3000;   // ถ้า .closed = true ภายใน 3 วิ = COOP
            var POLL_MS = 400;

            // =============================================
            // Init
            // =============================================
            document.addEventListener('DOMContentLoaded', function () {
                document.getElementById('btnOpenTab').addEventListener('click', openInfoTab);

                // รับ postMessage จาก Relay.aspx เมื่อ relay tab ปิด
                window.addEventListener('message', function (e) {
                    if (e.origin !== window.location.origin) return;
                    if (e.data && e.data.type === 'RELAY_CLOSING') {
                        setTimeout(function () {
                            if (tabActive && (!openedTab || openedTab.closed)) {
                                confirmClosed();
                            }
                        }, 200);
                    }
                });
            });

            // =============================================
            // เปิด Tab (พยายาม direct ก่อน)
            // =============================================
            function openInfoTab() {
                var url = document.getElementById('txtUrl').value.trim();
                if (!url) { showStatus('warning', '⚠️ กรุณาใส่ URL ก่อน'); return; }
                if (!/^https?:\/\//i.test(url)) url = 'https://' + url;

                // ถ้ามี tab เดิมที่ยังไม่ COOP และยังเปิดอยู่ → focus
                if (openedTab && !isCOOP) {
                    try { if (!openedTab.closed) { openedTab.focus(); return; } } catch (e) { }
                }

                resetState();

                // เปิด URL โดยตรง
                openedTab = window.open(url, '_blank');

                if (!openedTab) {
                    showStatus('warning', '⚠️ Popup ถูก browser บล็อก — กรุณา Allow popup สำหรับ localhost');
                    return;
                }

                openedAt = Date.now();
                tabActive = true;

                setButton(true, '⏳ กำลังดูข้อมูล...');
                showStatus('info', '&#x1F4C4; Tab ถูกเปิดแล้ว — รอผู้ใช้ปิด Tab...');

                // poll .closed
                pollTimer = setInterval(checkClosed, POLL_MS);
            }

            // =============================================
            // ตรวจ .closed ทุก POLL_MS
            // =============================================
            function checkClosed() {
                if (!tabActive) return;

                var closed = false;
                try { closed = openedTab.closed; } catch (e) { closed = true; }

                if (!closed) return; // ยังเปิดอยู่ — ปกติ

                var elapsed = Date.now() - openedAt;

                if (elapsed < GRACE_MS) {
                    // ─── COOP detected ───────────────────────────────
                    isCOOP = true;
                    clearInterval(pollTimer); pollTimer = null;

                    // auto-fallback → เปิดผ่าน Relay.aspx แทน
                    showStatus('warning',
                        '&#x1F512; หน้านี้ใช้ COOP — กำลังเปิดผ่าน Relay Page...');

                    setTimeout(function () { openViaRelay(); }, 1200);

                } else {
                    // ─── ปิดจริง (non-COOP) ─────────────────────────
                    clearInterval(pollTimer); pollTimer = null;
                    confirmClosed();
                }
            }

            // =============================================
            // Fallback: เปิดผ่าน Relay.aspx (สำหรับ COOP sites)
            // =============================================
            function openViaRelay() {
                var url = document.getElementById('txtUrl').value.trim();
                if (!/^https?:\/\//i.test(url)) url = 'https://' + url;

                openedTab = window.open(
                    'Relay.aspx?url=' + encodeURIComponent(url),
                    '_blank'
                );

                if (!openedTab) {
                    showStatus('warning', '⚠️ Popup ถูกบล็อก — กรุณา Allow popup แล้วกดปุ่มใหม่');
                    resetState();
                    setButton(false, '&#x2197; ดูข้อมูล');
                    return;
                }

                openedAt = Date.now();
                tabActive = true;

                showStatus('info',
                    '&#x1F517; เปิดผ่าน Relay Tab แล้ว — ' +
                    'ดูข้อมูล แล้ว<strong>ปิด Relay Tab</strong> เมื่อเสร็จ');

                // poll relay tab .closed (same-origin ไม่มีปัญหา COOP)
                pollTimer = setInterval(function () {
                    if (!tabActive) return;
                    if (openedTab && openedTab.closed) {
                        clearInterval(pollTimer); pollTimer = null;
                        confirmClosed();
                    }
                }, POLL_MS);
            }

            // =============================================
            // Tab ปิดแล้ว — trigger callback
            // =============================================
            function confirmClosed() {
                if (!tabActive) return;
                tabActive = false;
                openedTab = null;
                if (pollTimer) { clearInterval(pollTimer); pollTimer = null; }

                var method = isCOOP ? 'Relay Tab (.closed)' : 'Direct Tab (.closed)';
                showStatus('success',
                    '&#x2705; ผู้ใช้ปิด Tab แล้ว! — Default.aspx รับรู้เรียบร้อย ' +
                    '<small style="font-weight:normal; opacity:0.7;">(' + method + ')</small>');
                setButton(false, '&#x2197; ดูข้อมูล');
            }

            // =============================================
            // Helpers
            // =============================================
            function resetState() {
                tabActive = false; isCOOP = false;
                openedTab = null; openedAt = 0;
                if (pollTimer) { clearInterval(pollTimer); pollTimer = null; }
            }

            function setButton(busy, label) {
                var b = document.getElementById('btnOpenTab');
                b.disabled = busy;
                b.innerHTML = label;
            }

            function showStatus(type, msg) {
                var el = document.getElementById('tabStatus');
                el.style.display = 'block';
                var c = {
                    info: { bg: '#d9edf7', bd: '#bce8f1', tx: '#31708f' },
                    success: { bg: '#dff0d8', bd: '#d6e9c6', tx: '#3c763d' },
                    warning: { bg: '#fcf8e3', bd: '#faebcc', tx: '#8a6d3b' }
                }[type]
                    || { bg: '#d9edf7', bd: '#bce8f1', tx: '#31708f' };
                el.style.backgroundColor = c.bg;
                el.style.border = '1px solid ' + c.bd;
                el.style.color = c.tx;
                el.innerHTML = msg;
            }
        </script>

    </asp:Content>