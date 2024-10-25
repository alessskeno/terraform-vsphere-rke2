locals {

  namespaces = {
    # <Namespace name> = [<List of projects>]
    demo-namespace = ["demo-project"],
    minio = [
      "minio-middleware"
    ],
    watchtower = [
      "watchtower-api"
    ]
  }

  projects = {
    for v in flatten([
      #  <Project name> = {
      #  name = <Project name>,
      #  namespace = <Namespace name>
      #  }
      for ns, projs in local.namespaces : [
        for proj in projs : {
          name      = proj,
          namespace = ns
        }
      ]
    ]) : v.name => v
  }

}