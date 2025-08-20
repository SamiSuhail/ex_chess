# 0 - Just write chess in Elixir

You ran into Elixir one way or another, enjoyed it, went through some starter guides (perhaps a book or two) and are looking for an idea for the first serious project in your portfolio.

Don't be boring. 
Don't make another todo list app.
Don't use a bunch of generated boilerplate without diving deeper.
For the love of god, don't _vibecode_.

Do something **actually** cool.

## Make Elixir shine

Don't get me wrong, Elixir has such an amazing feel, ecosystem and community. I completely understand those for whom this is reason enough to endulge in it. 

But the real gold? It's underneath the surface. 

It's the BEAM. It's OTP.
The foundation that Erlang gifts us with. 
An extremely solid and battle-tested runtime. 

A VM that was built specifically for distributed systems, with concurrency and fault tolerance at it's core.
Also immutability. Freaking love immutability.

To make the ecosystem shine, your project needs to have some sort of statefulness and real-time communication. Yet another chatroom? Nah.

It needs to be fun.
Hell yeah. We're making our own multiplayer chess.

## What you can expect (in order? I think?)

- Chess game from scratch
- Realtime PVP with OTP
- Player VS AI (custom chess engine + stockfish integration)
- Phoenix + LiveView

The above roadmap is a very high-level view. We'll be getting into the nitty gritty of it all with the aims of building a functioning production application that we can then release. 

This won't be a short-term project. I **will** complete it though... I _hope_.

Don't just read the posts though, take part in it. Join the [discord](TODO) to help me plan, design, and review my work.
Because...

## Who am I?

Freaking nobody
For real, the best I've done using Elixir are a couple of hobby projects that I'm not proud enough to even make public on my GitHub.
This is as much of a learning experience for me as it is for you. Maybe more so even.

I've never worked on a production Elixir system.
This is the first time I am writing in a functional paradigm.
I am also not particularly good at chess.

I will back myself and say I'm pretty dang good at what I do though. 

## How are we doing this?

You're about to write and refactor a lot of code dude...
You'll first write the code yourself, then compare to my code and evaluate.
Don't be a lazy ****. You learn nothing that way.

I'll be giving you the requirements and acceptance criteria. Only once you're done with your own implementation will you start going through mine.

## The timeline

What are you my project manager? My scrum master?

## Up next

Soooo... The chess game. Version 0.
A board and some pieces. Nothing else.
The pieces can move, and you can list the valid moves for a piece.
Simple, right?

Well... not so fast. There will be practically no validation, other than the move being a valid movement pattern for that piece.
All the complexity of the game (and the code) will come in later on.