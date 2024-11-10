locals {

  namespaces = {
    # <Namespace name> = [<List of projects>]
    archman = [
      "archman-api",
      "archman-ui",
      "archman-agent"
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