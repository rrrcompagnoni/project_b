import Config

config :project_b,
  http_port: 4000

config :project_b,
  prefixes_path: "lib/project_b/priv/files/prefixes_test.txt"

config :project_b,
  business_sector_api: ProjectB.HTTPClients.BusinessSectorAPIFake
