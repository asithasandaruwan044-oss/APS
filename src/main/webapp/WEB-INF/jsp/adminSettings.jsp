<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
  <title>Admin Settings - ParkingPro</title>
  <style>
    body {
      font-family: 'Segoe UI', sans-serif;
      background: linear-gradient(rgba(0,0,0,0.8), rgba(0,0,0,0.8)), url('https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&q=80&w=2070');
      background-size: cover; background-attachment: fixed; color: white;
      display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0;
    }
    .settings-card {
      background: rgba(255, 255, 255, 0.1); backdrop-filter: blur(15px);
      padding: 40px; border-radius: 20px; border: 1px solid rgba(255, 255, 255, 0.2);
      width: 400px; text-align: center;
    }
    input[type="number"] {
      width: 100%; padding: 12px; margin: 20px 0; border-radius: 8px; border: none; font-size: 18px; text-align: center;
    }
    .update-btn {
      background: #ff9f43; color: black; border: none; padding: 12px 30px;
      border-radius: 8px; cursor: pointer; font-weight: bold; width: 100%; transition: 0.3s;
    }
    .update-btn:hover { background: #f39c12; transform: scale(1.02); }
    .back-link { display: block; margin-top: 20px; color: #2ecc71; text-decoration: none; font-size: 14px; }
  </style>
</head>
<body>
<div class="settings-card">
  <h2 style="color: #ff9f43; margin-bottom: 10px;">⚙️ System Settings</h2>

  <p style="opacity: 0.8; font-size: 14px;">Update total parking capacity</p>

  <form action="/updateSlots" method="post">
    <label>Total Parking Slots</label>
    <input type="number" name="newLimit" value="${totalSlots}" min="1" max="100" required>
    <button type="submit" class="update-btn">Update Capacity</button>
  </form>

  <a href="/dashboard" class="back-link">← Back to Dashboard</a>
</div>
</body>
</html>