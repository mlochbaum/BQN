*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/community/forums.html).*

# BQN chat forums

|           | Discord                                     | Matrix            | …in Element |
|-----------|---------------------------------------------|-------------------|-------------|
| All rooms | [**Invite**](https://discord.gg/SDTW36EhWF) | #array:matrix.org | [Space](https://app.element.io/#/room/%23array:matrix.org)
| BQN room  |                                             | #bqn:matrix.org   | [**Room**](https://app.element.io/#/room/%23bqn:matrix.org)

The BQN forum consists of a [Matrix](https://matrix.org/) channel, and one room in a [Discord](https://en.wikipedia.org/wiki/Discord_(software)) server, that are bridged together. Neither is primary and there are many users on each, and a few that use both. The Discord server contains rooms for array programming in general and for other languages such as APL, J, and k, and these are individually bridged to other Matrix channels.

#### Matrix

To avoid having to hunt down all these channels they're gathered into the Matrix space linked above. While Element supports spaces, many other clients don't. But as there's nothing special about the channels, once you join one in Element you'll be able to use it from any other Matrix client as well.

Being an open protocol, Matrix allows third-party clients (Element is first-party, created by the protocol's designers), and there are many available. Most are lacking in features or otherwise difficult to use. For a desktop client, [Nheko](https://github.com/Nheko-Reborn/nheko) seems to be the best chance of a good experience, and [FluffyChat](https://fluffychat.im/) should also be usable, although it's more mobile-focused.

#### BQNBot

BQNBot will run your code from chat! Begin your message with `bqn)` and our friend (designation B-QN) will evaluate the rest and show the output. In all cases `bqn)` has to be at the very start of the message, so start a new one if you say something before it. While putting your code in blocks `` `like this` `` is easier to read, the bot just operates on plain text and doesn't require it. For longer blocks, you can start a new line after `bqn)`, and use a multi-line code block, as shown below.

    bqn)
    ```
    some←code←↕10  # Comment
    code+some
    ```
