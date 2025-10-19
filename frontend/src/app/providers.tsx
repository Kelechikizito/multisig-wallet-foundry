"use client";

import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { type ReactNode, useState } from "react";
import { WagmiProvider } from "wagmi";
import {
  lightTheme,
  darkTheme,
  RainbowKitProvider,
} from "@rainbow-me/rainbowkit";
import config from "@/rainbowKitConfig";
import "@rainbow-me/rainbowkit/styles.css";
import { ThemeProvider, useTheme } from "@/contexts/ThemeContext";

// Inner component that uses the theme context
function RainbowKitThemeWrapper({ children }: { children: ReactNode }) {
  const { theme } = useTheme();

  return (
    <RainbowKitProvider
      theme={
        theme === "dark"
          ? darkTheme({ borderRadius: "medium" })
          : lightTheme({ borderRadius: "medium" })
      }
    >
      {children}
    </RainbowKitProvider>
  );
}

// Wrapper component for Wagmi and QueryClient
function WagmiWrapper({ children }: { children: ReactNode }) {
  const [queryClient] = useState(() => new QueryClient());

  return (
    <WagmiProvider config={config}>
      <QueryClientProvider client={queryClient}>
        <RainbowKitThemeWrapper>{children}</RainbowKitThemeWrapper>
      </QueryClientProvider>
    </WagmiProvider>
  );
}

// Main Providers component
export function Providers(props: { children: ReactNode }) {
  return (
    <ThemeProvider>
      <WagmiWrapper>{props.children}</WagmiWrapper>
    </ThemeProvider>
  );
}
