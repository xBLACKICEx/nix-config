let
  michiha = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPq0RVc3KjTQrLbzfzC7viY36rak5u1m3FCIHQyO77Uy michiha@agenix-recovery";
  suzuha = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFz1KKg/CEQjHbSM3fXJBvfQ3gqF47MkumUzymEXKEvh root@suzuha";
in
{
  "ionos-acme.env.age".publicKeys = [ michiha suzuha ];
}
