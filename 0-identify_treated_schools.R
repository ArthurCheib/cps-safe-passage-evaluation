library("RSocrata")

my_token <- readline(prompt = 'Insert token: ')
my_email <- readline(prompt = 'Insert email: ')
my_password <- readline(prompt = 'Insert password: ')

df <- read.socrata(url = "https://data.cityofchicago.org/resource/rq9p-k3zy.json",
                   app_token = my_token,
                   email     = my_email,
                   password  = my_password)
