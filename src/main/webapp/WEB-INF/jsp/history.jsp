<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html>
<head>
    <title>Parking History - Admin</title>
    <style>

        body {
            font-family: 'Segoe UI', sans-serif;
            background: linear-gradient(rgba(0,0,0,0.8), rgba(0,0,0,0.8)), url('https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&q=80&w=2070');
            background-size: cover; background-attachment: fixed; color: white;
            display: flex; justify-content: center; padding: 50px 20px;
        }
        .container { width: 100%; max-width: 1000px; background: rgba(255,255,255,0.1); backdrop-filter: blur(10px); padding: 30px; border-radius: 20px; border: 1px solid rgba(255,255,255,0.2); }

        .header { display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid rgba(255,255,255,0.2); padding-bottom: 15px; margin-bottom: 25px; }
        .earning-card { background: #ff9f43; color: black; padding: 10px 20px; border-radius: 10px; font-weight: bold; font-size: 18px; }

        /* Summary Boxes Styles */
        .summary-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; margin-bottom: 30px; }
        .summary-box { background: rgba(255, 255, 255, 0.05); padding: 20px; border-radius: 15px; border: 1px solid rgba(255, 255, 255, 0.1); max-height: 250px; overflow-y: auto; }
        .summary-box h4 { margin: 0 0 15px 0; color: #ff9f43; border-bottom: 1px solid rgba(255,159,67,0.3); padding-bottom: 8px; display: flex; align-items: center; gap: 8px; }
        .stat-row { display: flex; justify-content: space-between; font-size: 14px; padding: 8px 0; border-bottom: 1px solid rgba(255,255,255,0.05); }

        /* Table Styles */
        .table-wrapper { overflow-x: auto; margin-top: 20px; }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid rgba(255,255,255,0.1); }
        th { background: rgba(255,255,255,0.2); font-size: 14px; text-transform: uppercase; letter-spacing: 1px; }
        tr:hover { background: rgba(255,255,255,0.05); }

        .back-btn { display: inline-block; margin-top: 30px; text-decoration: none; color: #2ecc71; font-weight: bold; transition: 0.3s; }
        .back-btn:hover { transform: translateX(-5px); }
    </style>
</head>
<body>

<div class="container">

    <div class="header">
        <h2 style="margin:0;">📜 Parking History</h2>
        <div style="display: flex; gap: 15px;">
            <div class="earning-card" style="background: #2ecc71;">Today's: Rs. ${todayEarnings}.00</div>
            <div class="earning-card" style="background: #ff9f43; font-size: 14px; opacity: 0.9;">Grand Total: Rs. ${totalEarnings}.00</div>
        </div>
    </div>

    <div class="summary-grid">
        <div class="summary-box">
            <h4>📅 Daily Revenue</h4>
            <%
                java.util.Map<String, Long> daily = (java.util.Map<String, Long>) request.getAttribute("dailyEarnings");
                if(daily != null && !daily.isEmpty()) {
                    for(String date : daily.keySet()) {
            %>
            <div class="stat-row">
                <span><%= date %></span>
                <span style="color: #2ecc71; font-weight: bold;">Rs. <%= daily.get(date) %>.00</span>
            </div>
            <% } } else { %>
            <p style="opacity:0.5; font-size:13px;">No daily data available</p>
            <% } %>
        </div>

        <div class="summary-box">
            <h4>📊 Monthly Revenue</h4>
            <%
                java.util.Map<String, Long> monthly = (java.util.Map<String, Long>) request.getAttribute("monthlyEarnings");
                if(monthly != null && !monthly.isEmpty()) {
                    for(String month : monthly.keySet()) {
            %>
            <div class="stat-row">
                <span><%= month %></span>
                <span style="color: #ff9f43; font-weight: bold;">Rs. <%= monthly.get(month) %>.00</span>
            </div>
            <% } } else { %>
            <p style="opacity:0.5; font-size:13px;">No monthly data available</p>
            <% } %>
        </div>
    </div>

    <div class="table-wrapper">

        <div style="margin-bottom: 20px; display: flex; justify-content: flex-end;">
            <input type="text" id="historySearch" onkeyup="searchHistory()"
                   placeholder="🔎 Search by Vehicle No or Owner..."
                   style="padding: 10px; border-radius: 8px; border: 1px solid rgba(255,255,255,0.2);
                  background: rgba(255,255,255,0.1); color: white; width: 300px; outline: none;">
        </div>

        <h3 style="color: rgba(255,255,255,0.7); font-size: 16px;">Detailed Logs</h3>
        <table>
            <thead>
            <tr>
                <th>Slot</th><th>Vehicle No</th><th>Owner</th><th>Fee</th><th>Exit Time</th>
            </tr>
            </thead>
            <tbody>
            <%
                List<String[]> history = (List<String[]>) request.getAttribute("history");
                if (history != null && !history.isEmpty()) {
                    for (String[] h : history) {
            %>
            <tr>
                <td><b><%= h[0] %></b></td>
                <td><%= h[1] %></td>
                <td><%= h[2] %></td>
                <td style="color:#ff9f43; font-weight:bold;">Rs. <%= h[3] %>.00</td>
                <td style="font-size: 12px; opacity: 0.8;"><%= h[4] %></td>
            </tr>
            <% } } else { %>
            <tr><td colspan="5" style="text-align:center; opacity:0.5;">No history records found.</td></tr>
            <% } %>
            </tbody>
        </table>
        <div id="paginationControls" style="margin-top: 20px; display: flex; justify-content: center; gap: 10px;">
            <button onclick="prevPage()" id="btn_prev" class="page-btn">Previous</button>
            <span id="page_num" style="align-self: center; font-weight: bold; color: #ff9f43;"></span>
            <button onclick="nextPage()" id="btn_next" class="page-btn">Next</button>
        </div>

        <style>
            .page-btn {
                background: rgba(255, 255, 255, 0.1);
                border: 1px solid rgba(255, 255, 255, 0.2);
                color: white;
                padding: 5px 15px;
                border-radius: 5px;
                cursor: pointer;
            }
            .page-btn:hover { background: #ff9f43; color: black; }
            .page-btn:disabled { opacity: 0.3; cursor: not-allowed; }
        </style>

    </div>

    <a href="/dashboard" class="back-btn">← Back to Dashboard</a>
</div>
<script>
    function searchHistory() {
        let input = document.getElementById("historySearch").value.toUpperCase();
        let rows = document.querySelectorAll("tbody tr");

        rows.forEach(row => {
            // මෙහි 1 යනු Vehicle No සහ 2 යනු Owner නම ඇති Column එකයි
            let vehicleNo = row.cells[1] ? row.cells[1].innerText.toUpperCase() : "";
            let ownerName = row.cells[2] ? row.cells[2].innerText.toUpperCase() : "";

            if (vehicleNo.indexOf(input) > -1 || ownerName.indexOf(input) > -1) {
                row.style.display = "";
            } else {
                row.style.display = "none";
            }
        });
    }
</script>
<script>
    let currentPage = 1;
    let recordsPerPage = 10;
    let rows = document.querySelectorAll("tbody tr");

    function changePage(page) {
        let btn_next = document.getElementById("btn_next");
        let btn_prev = document.getElementById("btn_prev");
        let page_span = document.getElementById("page_num");

        // Validate page
        if (page < 1) page = 1;
        if (page > numPages()) page = numPages();

        // Hide all rows
        rows.forEach(row => row.style.display = "none");

        // Show only records for current page
        for (let i = (page - 1) * recordsPerPage; i < (page * recordsPerPage) && i < rows.length; i++) {
            rows[i].style.display = "";
        }

        page_span.innerHTML = "Page: " + page + " of " + numPages();

        // Disable/Enable buttons
        btn_prev.disabled = (page === 1);
        btn_next.disabled = (page === numPages());
    }

    function numPages() {
        return Math.ceil(rows.length / recordsPerPage);
    }

    function prevPage() {
        if (currentPage > 1) {
            currentPage--;
            changePage(currentPage);
        }
    }

    function nextPage() {
        if (currentPage < numPages()) {
            currentPage++;
            changePage(currentPage);
        }
    }

    // මුලින්ම පේජ් එක Load වන විට පළමු පිටුව පෙන්වීමට
    window.onload = function() {
        changePage(1);
    };
</script>
</body>
</html>