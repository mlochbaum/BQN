*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/community/forums.html).*

# BQN chat forums

|           | Discord                                     | Matrix            | …in Element |
|-----------|---------------------------------------------|-------------------|-------------|
| All rooms | [**Invite**](https://discord.gg/SDTW36EhWF) | #array:matrix.org | [Space](https://app.element.io/#/room/%23array:matrix.org)
| BQN room  |                                             | #bqn:matrix.org   | [**Room**](https://app.element.io/#/room/%23bqn:matrix.org)

The BQN forum consists of a [Matrix](https://matrix.org/) channel, and one room in a [Discord](https://en.wikipedia.org/wiki/Discord_(software)) server, that are bridged together. Neither is primary and there are many users on each, and a few that use both. The Discord server contains rooms for array programming in general and for other languages such as APL, J, and k, and these are individually bridged to other Matrix channels.

#### Matrix

To avoid having to hunt down all these channels they're gathered into the Matrix space linked above. Most clients don't yet support spaces; you can enable them as a beta feature and join the space to see the channels in it. There's nothing special about the channels so once you join one you'll be able to use it from any other Matrix client as well.

Being an open protocol, Matrix allows third-party clients (Element is first-party, created by the protocols designers), and there are many available. Most are lacking in features or otherwise difficult to use. For a desktop client, [Nheko](https://github.com/Nheko-Reborn/nheko) seems to be the best chance of a good experience.

#### BQNBot

BQNBot will run your code from chat! Begin your message with `bqn)` and our friend (designation B-QN) will evaluate the rest and show the output. While putting your code in blocks `` `like this` `` is easier to read, the bot just operates on plain text and doesn't require it. For longer blocks, you can start a new line after `bqn)`, and use a multi-line code block, as shown below.

    bqn)
    ```
    some←code←↕10  # Comment
    code+some
    ```
