import Config

config :car_rental, CarRental.Scheduler,
  jobs: [
    update_weekly_score: [
      schedule: {:extended, "*/10"},
      task: {CarRental.Clients.Supervisor, :update_weekly_score, []}
    ]
  ]
