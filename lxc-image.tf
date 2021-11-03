resource "null_resource" "lxc-image-update" {
  depends_on = [null_resource.local-prep]
  triggers = {
    files = sha1(join("", [for f in fileset(path.cwd, "lxc-image/*"): filesha1(f)]))
  }
  provisioner "local-exec" {
    command = "./update.sh"
    working_dir = "lxc-image"
  }
}
