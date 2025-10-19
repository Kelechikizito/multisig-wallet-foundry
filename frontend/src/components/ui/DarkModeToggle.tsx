"use client";

import { Moon, Sun } from "lucide-react";
import { useTheme } from "@/contexts/ThemeContext";

export default function DarkModeToggle() {
  const { theme, toggleTheme } = useTheme();

  return (
    <button
      onClick={toggleTheme}
      className="relative p-2 rounded-lg bg-gray-100 dark:bg-gray-800 hover:bg-gray-200 dark:hover:bg-gray-700 transition-all duration-200"
      aria-label="Toggle dark mode"
      title={theme === "light" ? "Switch to dark mode" : "Switch to light mode"}
    >
      {/* Sun Icon - visible in dark mode */}
      <Sun className="h-5 w-5 text-yellow-500 absolute inset-0 m-auto rotate-0 scale-100 transition-all duration-300 dark:-rotate-90 dark:scale-0" />

      {/* Moon Icon - visible in light mode */}
      <Moon className="h-5 w-5 text-gray-700 dark:text-blue-400 rotate-90 scale-0 transition-all duration-300 dark:rotate-0 dark:scale-100" />
    </button>
  );
}
