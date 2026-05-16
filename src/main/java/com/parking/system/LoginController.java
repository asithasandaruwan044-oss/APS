package com.parking.system;

import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import jakarta.servlet.http.HttpSession;
import java.util.*;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.ui.Model;
import java.io.*;

@Controller
public class LoginController {

    private final DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

    @GetMapping("/login")
    public String showLoginPage() {
        return "login";
    }

    @PostMapping("/login")
    public String login(@RequestParam String username, @RequestParam String password, HttpSession session, Model model) {
        try {
            File userFile = new File("users.txt");
            if (userFile.exists()) {
                BufferedReader br = new BufferedReader(new FileReader(userFile));
                String line;
                while ((line = br.readLine()) != null) {
                    String[] details = line.split(",");
                    if (details[0].trim().equals(username) && details[1].trim().equals(password)) {
                        session.setAttribute("userRole", details[2].trim());
                        session.setAttribute("userName", username);
                        br.close();
                        return "redirect:/dashboard";
                    }
                }
                br.close();
            }
        } catch (IOException e) { e.printStackTrace(); }

        model.addAttribute("error", "Invalid Credentials!");
        return "login";
    }

    @GetMapping("/dashboard")
    public String showDashboard(Model model) {
        List<String[]> vehicleList = new ArrayList<>();
        int totalSlots = getTotalSlots();

        try {
            File vFile = new File("vehicles.txt");
            if (vFile.exists()) {
                BufferedReader br = new BufferedReader(new FileReader(vFile));
                String line;
                while ((line = br.readLine()) != null) {
                    String[] data = line.split(",");
                    if(data.length >= 5) vehicleList.add(data);
                }
                br.close();
            }
        } catch (IOException e) { e.printStackTrace(); }

        model.addAttribute("totalSlots", totalSlots); // මේක JSP එකට යවන්න ඕනේ
        model.addAttribute("vehicles", vehicleList);
        model.addAttribute("availableSlots", totalSlots - vehicleList.size());

        return "dashboard";
    }

    @PostMapping("/addVehicle")
    public String addVehicle(@RequestParam String vNumber, @RequestParam String owner, @RequestParam String model) {
        try {
            int totalSlots = getTotalSlots(); // අලුත් limit එක ගන්න
            List<String[]> currentVehicles = new ArrayList<>();
            File file = new File("vehicles.txt");
            if (file.exists()) {
                BufferedReader br = new BufferedReader(new FileReader(file));
                String line;
                while ((line = br.readLine()) != null) currentVehicles.add(line.split(","));
                br.close();
            }

            if (currentVehicles.size() < totalSlots) {
                String assignedSlot = "";
                for (int i = 1; i <= totalSlots; i++) {
                    String slotName = "Slot-" + String.format("%02d", i);
                    boolean isOccupied = false;
                    for (String[] v : currentVehicles) {
                        if (v[0].trim().equals(slotName)) { isOccupied = true; break; }
                    }
                    if (!isOccupied) { assignedSlot = slotName; break; }
                }

                String entryTime = LocalDateTime.now().format(formatter);
                BufferedWriter bw = new BufferedWriter(new FileWriter("vehicles.txt", true));
                bw.write(assignedSlot + "," + vNumber.trim() + "," + owner.trim() + "," + model.trim() + "," + entryTime);
                bw.newLine();
                bw.close();
            }
        } catch (IOException e) { e.printStackTrace(); }
        return "redirect:/dashboard";
    }

    @GetMapping("/deleteVehicle")
    public String deleteVehicle(@RequestParam String vNumber, Model model) {
        String owner = "";
        String slot = "";
        long fee = 0;
        long minutes = 0;
        boolean isRemoved = false;

        try {
            List<String> remainingLines = new ArrayList<>();
            File file = new File("vehicles.txt");
            if(file.exists()){
                BufferedReader br = new BufferedReader(new FileReader(file));
                String line;
                while ((line = br.readLine()) != null) {
                    String[] details = line.split(",");
                    if (details[1].trim().equals(vNumber.trim())) {
                        slot = details[0];
                        owner = details[2];
                        LocalDateTime entryTime = LocalDateTime.parse(details[4].trim(), formatter);
                        Duration duration = Duration.between(entryTime, LocalDateTime.now());
                        minutes = Math.max(1, duration.toMinutes());
                        fee = Math.max(50, minutes * 2);
                        isRemoved = true;
                    } else {
                        remainingLines.add(line);
                    }
                }
                br.close();
            }

            if (isRemoved) {
                PrintWriter pw = new PrintWriter(new FileWriter("vehicles.txt"));
                for (String l : remainingLines) pw.println(l);
                pw.close();

                try (BufferedWriter historyBw = new BufferedWriter(new FileWriter("history.txt", true))) {
                    String exitTime = LocalDateTime.now().format(formatter);
                    historyBw.write(slot + "," + vNumber + "," + owner + "," + fee + "," + exitTime);
                    historyBw.newLine();
                }
            }

            model.addAttribute("vNumber", vNumber);
            model.addAttribute("owner", owner);
            model.addAttribute("minutes", minutes);
            model.addAttribute("fee", fee);

        } catch (Exception e) { e.printStackTrace(); }

        return "invoice";
    }

    @GetMapping("/history")
    public String showHistory(HttpSession session, Model model) {
        String role = (String) session.getAttribute("userRole");
        if (role == null || !role.equals("ADMIN")) return "redirect:/dashboard";

        List<String[]> historyList = new ArrayList<>();
        long totalEarnings = 0;
        long todayEarnings = 0;
        String todayDate = java.time.LocalDate.now().toString();

        Map<String, Long> dailyEarnings = new LinkedHashMap<>();
        Map<String, Long> monthlyEarnings = new LinkedHashMap<>();

        try {
            File file = new File("history.txt");
            if (file.exists()) {
                BufferedReader br = new BufferedReader(new FileReader(file));
                String line;
                while ((line = br.readLine()) != null) {
                    if (line.trim().isEmpty()) continue;
                    String[] data = line.split(",");
                    if (data.length >= 5) {
                        historyList.add(data);
                        try {
                            long fee = Long.parseLong(data[3].trim());
                            totalEarnings += fee;

                            // දින ආකෘතිය නිවැරදිව වෙන් කරගැනීම
                            String date = data[4].trim().split(" ")[0];
                            String month = date.substring(0, 7);

                            if (date.equals(todayDate)) todayEarnings += fee;

                            dailyEarnings.put(date, dailyEarnings.getOrDefault(date, 0L) + fee);
                            monthlyEarnings.put(month, monthlyEarnings.getOrDefault(month, 0L) + fee);
                        } catch (Exception e) { System.out.println("Error parsing fee/date: " + line); }
                    }
                }
                br.close();
            }
        } catch (IOException e) { e.printStackTrace(); }

        model.addAttribute("history", historyList);
        model.addAttribute("totalEarnings", totalEarnings);
        model.addAttribute("todayEarnings", todayEarnings);
        model.addAttribute("dailyEarnings", dailyEarnings);
        model.addAttribute("monthlyEarnings", monthlyEarnings);

        return "history";
    }

    @GetMapping("/userManagement")
    public String userManagement(HttpSession session, Model model) {
        String role = (String) session.getAttribute("userRole");
        if (role == null || !role.equals("ADMIN")) return "redirect:/dashboard";

        List<String[]> userList = new ArrayList<>();
        try {
            File uFile = new File("users.txt");
            if (uFile.exists()) {
                BufferedReader br = new BufferedReader(new FileReader(uFile));
                String line;
                while ((line = br.readLine()) != null) {
                    String[] uData = line.split(",");
                    if(uData.length >= 3) userList.add(uData);
                }
                br.close();
            }
        } catch (IOException e) { e.printStackTrace(); }

        model.addAttribute("allUsers", userList);
        return "userManagement";
    }

    @PostMapping("/addUser")
    public String addUser(@RequestParam String newUsername, @RequestParam String newPassword, @RequestParam String role, HttpSession session) {
        String userRole = (String) session.getAttribute("userRole");
        if (userRole != null && userRole.equals("ADMIN")) {
            try {
                try (PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter("users.txt", true)))) {
                    out.println(newUsername.trim() + "," + newPassword.trim() + "," + role.trim());
                }
            } catch (IOException e) { e.printStackTrace(); }
        }
        return "redirect:/userManagement";
    }

    @GetMapping("/deleteUser")
    public String deleteUser(@RequestParam String username, HttpSession session) {
        String role = (String) session.getAttribute("userRole");
        String currentUser = (String) session.getAttribute("userName");

        if (role != null && role.equals("ADMIN") && !currentUser.equals(username)) {
            try {
                List<String> lines = new ArrayList<>();
                File file = new File("users.txt");
                if(file.exists()){
                    BufferedReader br = new BufferedReader(new FileReader(file));
                    String line;
                    while ((line = br.readLine()) != null) {
                        if (!line.startsWith(username + ",")) lines.add(line);
                    }
                    br.close();

                    PrintWriter pw = new PrintWriter(new FileWriter("users.txt"));
                    for (String l : lines) pw.println(l);
                    pw.close();
                }
            } catch (IOException e) { e.printStackTrace(); }
        }
        return "redirect:/userManagement";
    }

    @GetMapping("/logout")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/login";
    }

    // Slots ගණන කියවීමට
    private int getTotalSlots() {
        try {
            File file = new File("settings.txt");
            if (file.exists()) {
                BufferedReader br = new BufferedReader(new FileReader(file));
                String line = br.readLine();
                br.close();
                if (line != null) return Integer.parseInt(line.trim());
            }
        } catch (Exception e) { e.printStackTrace(); }
        return 10; // ෆයිල් එක නැත්නම් default 10යි
    }

    // Slots ගණන Dashboard එකෙන් Update කිරීමට
    @PostMapping("/updateSlots")
    public String updateSlots(@RequestParam int newLimit, HttpSession session, RedirectAttributes ra) {
        String role = (String) session.getAttribute("userRole");
        if (role != null && role.equals("ADMIN")) {
            try (PrintWriter out = new PrintWriter(new FileWriter("settings.txt"))) {
                out.print(newLimit);
            } catch (IOException e) { e.printStackTrace(); }
        }
        ra.addFlashAttribute("msg", "Capacity Updated Successfully!");
        return "redirect:/adminSettings";
    }

    @GetMapping("/adminSettings")
    public String showSettings(HttpSession session, Model model) {
        String role = (String) session.getAttribute("userRole");
        if (role == null || !role.equals("ADMIN")) {
            return "redirect:/dashboard";
        }
        model.addAttribute("totalSlots", getTotalSlots());
        return "adminSettings"; // නිවැරදියි - මෙතනින් jsp එක ලෝඩ් කරනවා
    }
}