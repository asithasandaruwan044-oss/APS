<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ page import="java.util.List" %>

<!DOCTYPE html>

<html>

<head>

    <title>Dashboard - Vehicle Parking System</title>

    <style>

        .filtered-out { display: none !important; }

        body {

            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;

            margin: 0; padding: 0;

            background: linear-gradient(rgba(0, 0, 0, 0.7), rgba(0, 0, 0, 0.7)),

            url('https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&q=80&w=2070');

            background-size: cover; background-attachment: fixed; background-position: center;

            color: white; display: flex; flex-direction: column; align-items: center;

        }



        /* Navbar Styles */

        .navbar {
            width: 100%;
            padding: 15px 50px;
            background: rgba(0, 0, 0, 0.6);
            backdrop-filter: blur(10px);
            display: flex;
            justify-content: space-between; /* මේකෙන් තමයි Logo එක සහ Links දෙපැත්තට කරන්නේ */
            align-items: center;
            box-sizing: border-box;
            position: sticky;
            top: 0;
            z-index: 1000;
        }

        .nav-links { display: flex; gap: 15px; align-items: center; }

        .nav-links a {

            color: white; text-decoration: none; font-weight: 500; font-size: 14px;

            padding: 10px 18px; border-radius: 8px; transition: 0.3s;

            display: flex; align-items: center; gap: 8px;

        }

        .nav-links a:hover { background: rgba(255, 255, 255, 0.15); }

        .nav-links a.active { background: #ff9f43; color: black; font-weight: bold; }



        .logout-btn { background: #ff4757; color: white; padding: 10px 20px; border-radius: 8px; text-decoration: none; font-weight: bold; font-size: 14px; transition: 0.3s; }

        .logout-btn:hover { background: #ff6b81; transform: scale(1.05); }



        /* Container & Layout */

        .container { width: 95%; max-width: 1200px; margin-top: 30px; padding: 20px; }

        .status-container { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-bottom: 30px; }



        .card { background: rgba(255, 255, 255, 0.1); backdrop-filter: blur(10px); padding: 20px; border-radius: 15px; border: 1px solid rgba(255, 255, 255, 0.2); text-align: center; transition: 0.3s; }

        .card:hover { transform: translateY(-5px); background: rgba(255, 255, 255, 0.2); border-color: #ff9f43; }

        .card h3 { margin: 0; font-size: 13px; opacity: 0.8; text-transform: uppercase; letter-spacing: 1px; }

        .card p { margin: 10px 0 0; font-size: 32px; font-weight: bold; }



        .main-content { display: flex; gap: 30px; flex-wrap: wrap; }

        .glass-box { background: rgba(255, 255, 255, 0.1); backdrop-filter: blur(10px); padding: 25px; border-radius: 15px; border: 1px solid rgba(255, 255, 255, 0.2); height: fit-content; }

        .form-section { flex: 1; min-width: 320px; }

        .table-section { flex: 2; min-width: 500px; }



        /* Table & Form Elements */

        table { width: 100%; border-collapse: collapse; margin-top: 10px; }

        th { background: rgba(255, 255, 255, 0.15); padding: 12px; text-align: left; font-size: 14px; }

        td { padding: 12px; border-bottom: 1px solid rgba(255, 255, 255, 0.1); font-size: 14px; }



        input[type="text"] { width: 100%; padding: 12px; margin: 8px 0 18px 0; border-radius: 8px; border: none; background: rgba(255, 255, 255, 0.9); box-sizing: border-box; font-size: 14px; color: black; }

        label { font-size: 13px; font-weight: bold; color: rgba(255, 255, 255, 0.9); }



        .save-btn { width: 100%; padding: 14px; border: none; border-radius: 8px; background: #2ecc71; color: white; font-weight: bold; cursor: pointer; font-size: 15px; transition: 0.3s; }

        .save-btn:hover { background: #27ae60; box-shadow: 0 5px 15px rgba(46, 204, 113, 0.3); }

        .save-btn:disabled { background: #95a5a6; cursor: not-allowed; }



        .delete-link { background: rgba(255, 71, 87, 0.2); color: #ff4757; padding: 5px 12px; border-radius: 5px; text-decoration: none; font-weight: bold; font-size: 12px; transition: 0.3s; }

        .delete-link:hover { background: #ff4757; color: white; }

    </style>

</head>

<body>



<%

    String role = (String) session.getAttribute("userRole");

    String userName = (String) session.getAttribute("userName");

%>



<div class="navbar">
    <h2 style="margin:0; font-size: 22px;">🅿️ ParkingPro</h2>

    <div class="nav-links">
        <a href="/dashboard" class="active">🏠 Dashboard</a>
        <% if (role != null && role.equals("ADMIN")) { %>
        <a href="/userManagement">👥 User Management</a>
        <a href="/history">📜 History Logs</a>
        <a href="/adminSettings">⚙️ Admin Settings</a>
        <% } %>
    </div>

    <div style="display: flex; align-items: center; gap: 20px;">
        <span style="font-size: 13px; opacity: 0.8;">Welcome, <b><%= userName %></b></span>
        <a href="/logout" class="logout-btn">Logout</a>
    </div>
</div>



<div class="container">



    <div class="status-container">

        <div class="card" onclick="filterSlots('all')" style="cursor:pointer; border-bottom: 4px solid white;">

            <h3>Total Slots</h3>

            <p>${totalSlots}</p>

        </div>

        <div class="card" onclick="filterSlots('occupied')" style="cursor:pointer; border-bottom: 4px solid #ff9f43;">

            <h3>Occupied</h3>

            <p>${vehicles.size()}</p>

        </div>

        <div class="card" onclick="filterSlots('free')" style="cursor:pointer; border-bottom: 4px solid #2ecc71;">

            <h3>Free Slots</h3>

            <p>${availableSlots}</p>

        </div>


    </div>



    <div class="main-content">

        <div class="glass-box form-section">

            <h3 style="margin-top:0; color: #ff9f43;">🚗 Register Vehicle</h3>

            <form action="/addVehicle" method="post">

                <label>Vehicle Number</label>

                <input type="text" name="vNumber" placeholder="Ex: WP CAS-1234" required>



                <label>Owner Name</label>

                <input type="text" name="owner" placeholder="Owner Name" required>



                <label>Vehicle Model</label>

                <input type="text" name="model" placeholder="Vehicle Model" required>



                <button type="submit" class="save-btn" <%= ((Integer)request.getAttribute("availableSlots") <= 0) ? "disabled" : "" %>>

                    CONFIRM & PARK

                </button>

            </form>

        </div>



        <div class="glass-box table-section">

            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">

                <h3 style="margin: 0; color: #ff9f43;">📊 Real-time Parking Status</h3>

                <input type="text" id="searchInput" onkeyup="searchVehicle()" placeholder="🔎 Search Vehicle..." style="width: 200px; padding: 10px 15px; border-radius: 20px; border: none; color: black; font-size: 13px;">

            </div>



            <table>

                <thead>

                <tr>

                    <th>Slot / Plate</th>

                    <th>Owner</th>

                    <th>Model</th>

                    <th>Entry Time</th>

                    <th>Action</th>

                </tr>

                </thead>

                <tbody>
                <%
                    List<String[]> vList = (List<String[]>) request.getAttribute("vehicles");
                    // getTotalSlots() වලින් එන අගය මෙතනට ගන්නවා
                    int totalSlotsFromAttr = (Integer) request.getAttribute("totalSlots");

                    for (int i = 1; i <= totalSlotsFromAttr; i++) {
                        String slotLabel = "Slot-" + String.format("%02d", i);
                        String[] found = null;
                        if (vList != null) {
                            for (String[] v : vList) {
                                if (v[0].trim().equals(slotLabel)) { found = v; break; }
                            }
                        }

                        if (found != null) {
                %>
                <tr class="slot-row occupied-row">
                    <td><b style="color: #ff9f43;"><%= found[0] %></b><br><%= found[1] %></td>
                    <td><%= found[2] %></td>
                    <td><%= found[3] %></td>
                    <td style="font-size: 11px; opacity: 0.8;"><%= found[4] %></td>
                    <td>
                        <a href="/deleteVehicle?vNumber=<%= found[1] %>" class="delete-link"
                           onclick="return confirm('Release this vehicle and generate invoice?')">Exit</a>
                    </td>
                </tr>
                <% } else { %>
                <tr class="slot-row free-row">
                    <td><b><%= slotLabel %></b></td>
                    <td colspan="3" style="text-align:center; color: #2ecc71; opacity: 0.5; font-style: italic;">Available</td>
                    <td><span style="color:#2ecc71; font-weight: bold; font-size: 12px;">Empty</span></td>
                </tr>
                <% } } %>
                </tbody>

            </table>

            <div id="paginationControls" style="display: flex; justify-content: center; align-items: center; gap: 15px; margin-top: 20px;">
                <button onclick="prevPage()" id="btnPrev" style="background: rgba(255,255,255,0.1); color: white; border: 1px solid rgba(255,255,255,0.3); padding: 8px 15px; border-radius: 5px; cursor: pointer;">Previous</button>
                <span id="pageInfo" style="font-size: 14px; font-weight: bold; color: #ff9f43;"></span>
                <button onclick="nextPage()" id="btnNext" style="background: rgba(255,255,255,0.1); color: white; border: 1px solid rgba(255,255,255,0.3); padding: 8px 15px; border-radius: 5px; cursor: pointer;">Next</button>
            </div>

        </div>

    </div>

</div>



<script>

    let currentFilter = 'all'; // දැනට තෝරාගෙන ඇති filter එක මතක තබා ගැනීමට

    function filterSlots(type) {
        currentFilter = type; // filter එක update කරන්න
        currentPage = 1;      // අලුතින් filter කරද්දී ආපහු 1 වෙනි පිටුවට යන්න ඕනේ

        let rows = document.querySelectorAll(".slot-row");

        rows.forEach(row => {
            // filter එකට අනුව පේළි වලට 'filtered-out' class එක දාමු හෝ අයින් කරමු
            if (type === 'all') {
                row.classList.remove('filtered-out');
            } else if (type === 'occupied') {
                if (row.classList.contains('occupied-row')) row.classList.remove('filtered-out');
                else row.classList.add('filtered-out');
            } else if (type === 'free') {
                if (row.classList.contains('free-row')) row.classList.remove('filtered-out');
                else row.classList.add('filtered-out');
            }
        });

        displayTable(); // දැන් pagination එක්ක table එක පෙන්වන්න
    }



    function searchVehicle() {
        let input = document.getElementById("searchInput").value.toUpperCase();
        let rows = document.querySelectorAll(".slot-row");
        let pagination = document.getElementById("paginationControls");

        if (input === "") {
            pagination.style.display = "flex"; // Search එක හිස් නම් ආයෙත් pagination පෙන්වන්න
            displayTable();
        } else {
            pagination.style.display = "none"; // Search කරද්දී pagination හංගන්න
            rows.forEach(row => {
                let text = row.innerText.toUpperCase();
                row.style.display = text.includes(input) ? "" : "none";
            });
        }
    }

    let currentPage = 1;
    const recordsPerPage = 8; // පිටුවකට පෙන්වන පේළි ගණන

    function displayTable() {
        // filter එකෙන් පස්සේ ඉතිරි වුණු පේළි ටික විතරක් ගන්න
        let allRows = Array.from(document.querySelectorAll(".slot-row"));
        let visibleRows = allRows.filter(row => !row.classList.contains('filtered-out'));

        let totalPages = Math.ceil(visibleRows.length / recordsPerPage);
        if (totalPages === 0) totalPages = 1;

        // මුලින්ම හැම පේළියක්ම හංගන්න
        allRows.forEach(row => row.style.display = "none");

        // දැනට ඉන්න පිටුවට අදාළ visible පේළි විතරක් පෙන්වන්න
        visibleRows.forEach((row, index) => {
            if (index >= (currentPage - 1) * recordsPerPage && index < currentPage * recordsPerPage) {
                row.style.display = "";
            }
        });

        // Pagination controls update කරන්න
        document.getElementById("pageInfo").innerText = "Page " + currentPage + " of " + totalPages;
        document.getElementById("btnPrev").disabled = (currentPage === 1);
        document.getElementById("btnNext").disabled = (currentPage === totalPages || visibleRows.length === 0);

        document.getElementById("btnPrev").style.opacity = (currentPage === 1) ? "0.5" : "1";
        document.getElementById("btnNext").style.opacity (currentPage === totalPages || visibleRows.length === 0) ? "0.5" : "1";
    }

    function prevPage() {
        if (currentPage > 1) {
            currentPage--;
            displayTable();
        }
    }

    function nextPage() {
        let rows = document.querySelectorAll(".slot-row").length;
        if (currentPage < Math.ceil(rows / recordsPerPage)) {
            currentPage++;
            displayTable();
        }
    }

    // පිටුව load වෙද්දීම table එක හරිගස්සන්න
    window.onload = function() {
        displayTable();
    };

</script>

</body>

</html>