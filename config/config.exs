import Config

config :gitlab_ex,
  v4_base_url: "https://git-p1ap1.divvy.co/api/v4/",
  token: System.get_env("JARVIS_GITLAB_TOKEN")
