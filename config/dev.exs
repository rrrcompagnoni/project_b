import Config

config :project_b,
  http_port: 8080

config :project_b,
  prefixes_path: "lib/project_b/priv/files/prefixes.txt"

config :project_b,
  business_sector_api: ProjectB.HTTPClients.BusinessSectorAPI
