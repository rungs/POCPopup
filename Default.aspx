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
            // ส่วนมัดรวมสถานะ (State)
            // =============================================
            var openedTab = null;   // ตัวแปรเก็บ Reference (หน้าต่าง) ของ Tab ที่เปิดใหม่
            var pollTimer = null;   // ตัวแปรเก็บ ID ของตัวจับเวลา (Timer) สำหรับตรวจสอบสถานะ
            var POLL_MS = 400;      // ตั้งค่าความถี่ในการตรวจสอบ (0.4 วินาที)

            // =============================================
            // เริ่มต้นการทำงาน (Initial)
            // =============================================
            document.addEventListener('DOMContentLoaded', function () {
                // ผูกเหตุการณ์เมื่อกดปุ่ม ให้เรียกฟังก์ชันเปิด Tab
                document.getElementById('btnOpenTab').addEventListener('click', openInfoTab);
            });

            // =============================================
            // ฟังก์ชันสำหรับเปิด Tab และเริ่มการตรวจสอบ
            // =============================================
            function openInfoTab() {
                var url = document.getElementById('txtUrl').value.trim();

                // ตรวจสอบความถูกต้องของ URL เบื้องต้น
                if (!url) { showStatus('warning', '⚠️ กรุณาใส่ URL ก่อน'); return; }
                if (!/^https?:\/\//i.test(url)) url = 'https://' + url;

                // ตรวจสอบว่าถ้ามี Tab เดิมเปิดอยู่แล้ว และยังไม่ได้ปิด ให้ย้ายโฟกัสไปที่หน้านั้นแทนการเปิดใหม่
                if (openedTab && !openedTab.closed) {
                    openedTab.focus();
                    return;
                }

                // สั่งเปิด URL ไปที่หน้าต่างใหม่ (_blank)
                openedTab = window.open(url, '_blank');

                // กรณีที่ Browser บล็อก Popup
                if (!openedTab) {
                    showStatus('warning', '⚠️ Popup ถูกบล็อก — กรุณา Allow popup ใน Browser');
                    return;
                }

                // ปรับแต่ง UI ให้ดูเหมือนระบบกำลังประมวลผล
                setButton(true, '⏳ กำลังดูข้อมูล...');
                showStatus('info', '&#x1F4C4; เปิดหน้าเว็บแล้ว — ระบบจะตรวจสอบ "อัตโนมัติ" เมื่อคุณปิด Tab นั้น');

                // เริ่มกระบวนการจับเวลาตรวจสอบ (Polling)
                if (pollTimer) clearInterval(pollTimer);

                // สั่งให้รันฟังก์ชัน checkClosed ทุกๆ 0.4 วินาที
                pollTimer = setInterval(checkClosed, POLL_MS);
            }

            // =============================================
            // ฟังก์ชันตรวจสอบสถานะความคืบหน้า (Polling Function)
            // =============================================
            function checkClosed() {
                // หัวใจสำคัญ: .closed คือ Property เดียวที่อนุญาตให้อ่านข้าม Domain (Cross-Origin) ได้
                // เมื่อไหร่ก็ตามที่ผู้ใช้ปิดหน้าต่างเป้าหมาย .closed จะเปลี่ยนเป็น true
                if (openedTab && openedTab.closed) {
                    // หยุดตัวจับเวลา และแจ้งเตือน
                    clearInterval(pollTimer);
                    pollTimer = null;
                    confirmClosed();
                }
            }

            // =============================================
            // ฟังก์ชันแจ้งเตือนเมื่อตรวจพบการปิด Tab สำเร็จ
            // =============================================
            function confirmClosed() {
                openedTab = null;
                showStatus('success', '&#x2705; ตรวจพบการปิด Tab แล้ว! (สถานะ: .closed = true)');
                setButton(false, '&#x2197; ดูข้อมูล');
            }

            // =============================================
            // ฟังก์ชันช่วยจัดการ UI (Helpers)
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