'use client';

// ============================================================================
// 🔒 LOCKED MODULE - Day 04
// This module will be unlocked when students reach Day 04
// ============================================================================

export default function GovernanceModule() {
  return (
    <div className="cyber-card-locked p-12 text-center">
      <div className="text-6xl mb-4">🔒</div>
      <h2 className="text-2xl font-bold text-gray-400 mb-4">
        Governance Module Locked
      </h2>
      <p className="text-gray-500 max-w-md mx-auto">
        This module requires the Governor and ERC20Votes contracts from Day 04.
        Complete Day 04 exercises to unlock governance features.
      </p>
      
      <div className="mt-8 p-4 bg-cyber-dark rounded border border-gray-700">
        <h3 className="font-bold text-gray-500 mb-3">Coming in Day 04:</h3>
        <ul className="text-left text-gray-500 text-sm space-y-2">
          <li>• Delegate voting power</li>
          <li>• Create proposals</li>
          <li>• Vote on proposals (For / Against / Abstain)</li>
          <li>• Execute passed proposals</li>
          <li>• Modify vault fees via governance</li>
        </ul>
      </div>
    </div>
  );
}
