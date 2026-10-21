# README

Lewis is an app for managing my personal library.

Currently there is a table view and you can sort it and filter it.

I have too many books and thought this would help. Maybe the key column is `location`, where this can be either "home" or the name of the person who has the book borrowed (looking at you, Ondřej). I don't harbor any hope of finding the books I borrowed aeons ago, but at least this tool can help me keep track of them in the future.

When creating a new book there is a `scan` feature. 
This sends an image to an agent with a prompt to return the author and title of the book in json form. This gets processed into a new Book.
You should have `ollama` installed for this, and a model running. I use `minicpm-v4.6:latest`, but I'm sure any model with vision will do. To point the app at the model, alter `example.env` with your address and model, and ```source example.env```

There is also a `tags` system. I don't like the traditional genre divisions used by bookkeepers. Instead I think that optimal genre classification for a library is subjective, and with this you should be able to make your own. 

Oh, and, don't forget to run `rails db:create` and `rails db:migrate`


Next steps, in no particular order:
    1. pagination. Prefer FE pagination, cuz I don't like paginated API responses
    2. for the scan book feature, only display it if the connection is available - otherwise just a message
    3. scan redirects to an open edit form (for last check)
    4. beautify `show`
    5. open scan as an API endpoint for my automatic python script that can load the books from a series of images
    6. Grid view - for mobile 
    7. Edit should diplay the image - should be `show` but editable
    8. shuffle around the filter toolbar to make it look better
    9. do the same with sorting
    10. filter by "books whose location is not home"
    11. open it up to my local network
    12. open it up to the internet