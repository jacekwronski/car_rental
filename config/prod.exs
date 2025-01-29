import Config

config :car_rental, CarRental.Scheduler,
  jobs: [
    {"@weekly", {CarRental.Clients.Supervisor, :update_weekly_score, []}}
  ]
