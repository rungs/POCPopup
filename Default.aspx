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
            var pollTimer = null;
            var POLL_MS = 400;      // ตรวจสอบทุก 0.4 วินาที

            // =============================================
            // Init
            // =============================================
            document.addEventListener('DOMContentLoaded', function () {
                document.getElementById('btnOpenTab').addEventListener('click', openInfoTab);
            });

            // =============================================
            // เปิด Tab โดยตรง
            // =============================================
            function openInfoTab() {
                var url = document.getElementById('txtUrl').value.trim();
                if (!url) { showStatus('warning', '⚠️ กรุณาใส่ URL ก่อน'); return; }
                if (!/^https?:\/\//i.test(url)) url = 'https://' + url;

                // ถ้ามี Tab เดิมเปิดอยู่แล้ว ให้ focus
                if (openedTab && !openedTab.closed) {
                    openedTab.focus();
                    return;
                }

                // สั่งเปิด URL
                openedTab = window.open(url, '_blank');

                if (!openedTab) {
                    showStatus('warning', '⚠️ Popup ถูกบล็อก — กรุณา Allow popup');
                    return;
                }

                setButton(true, '⏳ กำลังดูข้อมูล...');
                showStatus('info', '&#x1F4C4; เปิดหน้าเว็บแล้ว — ระบบกำลังรอให้คุณปิด Tab...');

                // เริ่มตรวจสอบสถานะการปิด
                if (pollTimer) clearInterval(pollTimer);
                pollTimer = setInterval(checkClosed, POLL_MS);
            }

            // =============================================
            // ตรวจสอบสถานะ .closed
            // =============================================
            function checkClosed() {
                if (openedTab && openedTab.closed) {
                    clearInterval(pollTimer);
                    pollTimer = null;
                    confirmClosed();
                }
            }

            // =============================================
            // เมื่อยืนยันว่า Tab ปิดแล้ว
            // =============================================
            function confirmClosed() {
                openedTab = null;
                showStatus('success', '&#x2705; ตรวจพบการปิด Tab แล้ว! (ตรวจจาก .closed property)');
                setButton(false, '&#x2197; ดูข้อมูล');
            }

            // =============================================
            // Helpers
            // =============================================
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
                }[type] || { bg: '#d9edf7', bd: '#bce8f1', tx: '#31708f' };

                el.style.backgroundColor = c.bg;
                el.style.border = '1px solid ' + c.bd;
                el.style.color = c.tx;
                el.innerHTML = msg;
            }
        </script>

    </asp:Content>