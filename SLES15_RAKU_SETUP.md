# 🧩 SLES15 Raku Runtime Installation Guide
# Version example: v0.0.2
# Target: SUSE Linux Enterprise Server 15 SP6/SP7 (x86_64)

============================================================
1️⃣ Copy runtime tarball to SLES
============================================================

From your local machine (macOS or build host):

  scp raku-runtime-0.0.2.tar.gz <user>@<sles-host>:~

Verify on the SLES server:

  ls -lh ~/raku-runtime-0.0.2.tar.gz

============================================================
2️⃣ Extract runtime into user directory
============================================================

On SLES:

  cd ~
  mkdir -p raku-0.0.2
  tar xzf raku-runtime-0.0.2.tar.gz -C raku-0.0.2 --strip-components=1

Check structure:

  ls ~/raku-0.0.2
  # should show bin/, lib/, share/, etc.

============================================================
3️⃣ Add Raku to your PATH
============================================================

Create a bin directory if not already present:

  mkdir -p ~/bin

Create a symbolic link:

  ln -sf ~/raku-0.0.2/bin/raku ~/bin/raku

Add to PATH permanently (if not yet done):

  echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
  source ~/.bashrc

Verify:

  which raku
  raku -v

Expected output example:

  Welcome to Rakudo™ v2025.10.
  Implementing the Raku® Programming Language v6.d.
  Built on MoarVM version 2025.10.

============================================================
4️⃣ Test the runtime and installed modules
============================================================

Check JSON::Fast (or other modules you included in modules.conf):

  raku -e 'use JSON::Fast; say "OK on SLES runtime";'

If you see:

  OK on SLES runtime

→ Your portable Raku runtime works correctly!

============================================================
5️⃣ Optional: Upgrade to a newer version later
============================================================

1. Copy the new release tarball (e.g., raku-runtime-0.0.3.tar.gz) to SLES.
2. Extract into a new directory:

     mkdir -p ~/raku-0.0.3
     tar xzf raku-runtime-0.0.3.tar.gz -C ~/raku-0.0.3 --strip-components=1

3. Update your symbolic link:

     ln -sf ~/raku-0.0.3/bin/raku ~/bin/raku

4. Test again:

     raku -v
     raku -e 'use JSON::Fast; say "OK upgraded runtime";'

============================================================
✅ Summary
============================================================

• No root privileges required.
• Entire Raku environment runs inside your $HOME.
• Each release is self-contained and switchable via symlink.
• Ideal for SLES servers without internet access.

============================================================
End of File
============================================================