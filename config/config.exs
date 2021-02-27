import Config

config :project_b,
  business_sector_endpoint: System.get_env("BUSINESS_SECTOR_ENDPOINT")

import_config "#{config_env()}.exs"
