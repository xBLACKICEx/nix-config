{
  lib,
  buildGoModule,
  fetchFromGitHub,
  python3,
}:

buildGoModule rec {
  pname = "agentdock";
  version = "0.8.3";

  src = fetchFromGitHub {
    owner = "uvwt";
    repo = "agentdock";
    rev = "v${version}";
    hash = "sha256-IQ+BBGEyLafk88f3c8fgTfOBbbYGk8f2WgK64dF5iI4=";
  };

  vendorHash = "sha256-Qs7Xk5Yb3pzxN48UMi1/Ahx2KrqsK1kPjjn7QElHRZM=";

  nativeBuildInputs = [ python3 ];

  env.CGO_ENABLED = "0";

  subPackages = [ "cmd/agentdock" ];

  # One upstream CLI test uses os.UserHomeDir() without replacing HOME. Nix
  # builders deliberately use /homeless-shelter, so give that test suite a
  # private writable home rather than disabling it.
  preCheck = ''
    export HOME="$TMPDIR/home"
    mkdir -p "$HOME"
  '';

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/uvwt/agentdock/internal/buildinfo.Commit=v${version}"
    "-X=github.com/uvwt/agentdock/internal/buildinfo.BuildDate=1970-01-01T00:00:00Z"
  ];

  postInstall = ''
    ${python3}/bin/python3 packaging/build-core-skill-bundle.py \
      --repo-root "$src" \
      --output "$out/share/agentdock/core-skills"
  '';

  meta = {
    description = "Secure MCP runtime for AI agents to operate machines, servers, and containers";
    homepage = "https://github.com/uvwt/agentdock";
    license = lib.licenses.asl20;
    mainProgram = "agentdock";
    platforms = lib.platforms.linux;
  };
}
