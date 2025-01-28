import Config

config :car_rental, CarRental.Scheduler,
  jobs: [
    update_weekly_score: [
      schedule: {:extended, "*/20"},
      task: {CarRental.Clients.Supervisor, :update_weekly_score, []}
    ]
  ]
