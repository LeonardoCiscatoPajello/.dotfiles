{ ... }:
{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    
    # Auto-optimize store
    auto-optimise-store = true;
    
    # Garbage collection
    max-free = 3000000000;  # 3GB
    min-free = 512000000;   # 512MB
  };
  
  # Auto garbage collect weekly
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
}# ⟦ΔΒ⟧
