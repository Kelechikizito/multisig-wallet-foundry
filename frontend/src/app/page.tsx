"use client";

import Image from "next/image";
// import HomeContent from "@/components/HomeContent";
import { useAccount } from "wagmi";
import Dashboard from "@/components/Dashboard";

export default function Home() {
  const { isConnected } = useAccount();
  return (
    <div>
      {isConnected ? (
        <div>
          <Dashboard />
        </div>
      ) : (
        <div>Please connect a wallet ...</div>
      )}
    </div>
  );
}
