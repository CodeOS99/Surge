# SURGE!

*SURGE!* is a game made for a game jam in 3 weeks with the theme **Wave**.

[ITCH PAGE!](https://codeos99.itch.io/surge)

### The story:

You've died! But thankfully(?), the sadistic grim reaper has allowed you a chance at living: you must continue harvesting souls, for the rest of your life, while stranded on an island. You took the deal.

---

## Controls

- **Move:** WASD / Arrow Keys  
- **Sprint:** Control  
- **Use Axe (Chop):** E  
- **Pickup:** Left Shift  
- **Drop:** Q  
- **Drop everything in inventory:** Alt + Q  
- **Attack:** Right Click  
- **Toggle Inventory:** Space / Enter  
- **Move stacks:** Hold Left Mouse Button  
- **Move a single item:** Hold Left Mouse Button, then Right Mouse Button  
- **Eat food:** Drag & drop food on the player's drop area  
- **Fuel extractors:** Drag & drop fuel on mineral extractors to move them forward in time  

---

# GUIDE

The game's a bit complex to figure out on your own in the beginning, so refer to this guide for information on everything in the game currently.

The overworld, where you spawn, is procedurally generated.  

---

## TL;DR

- Eat food or transfer between worlds to regenerate hunger, stamina, and health.  
- In inventory (left to right): storage, crafting, (hover over the rest in-game).  
- More foraging points = more loot  
- Extractors are the **only** way to get minerals. Craft, place, and fuel them.  
- You’ll be transferred to the **soulyard** at midnight. Defeat enemies to return.  
- Crafting recipes matter! **Item placement is important**  
- Stones are everywhere—grab them!  

---

## Game Loop

The main game loop revolves around collecting resources in the overworld, then being teleported by the Reaper to the **soulyard** to harvest souls from entities too stubborn to give them up.

You do this... by beating them up.

In the overworld:  
Gather food, wood, iron, coal, gold, diamonds, etc.  
Craft better gear.  
Prepare to survive waves of enemies in the soulyard, which you are taken to every midnight.

---

## Systems

Multiple things may be happening at the same time, so here’s an overview:

- **Health:** Depleted = death. Regain by eating or transferring between worlds.  
- **Stamina:** Used for attacking and chopping. Regain by standing still, eating, or transferring.  
- **Hunger:** Depletes every 3 seconds. When empty, you take damage. Regain by eating or transferring.  
- **Foraging Points:** More points = better loot per tree. Earn 1 point per chop.  
- **Inventory:**  
  - Open with `Space`  
  - **4x4 grid:** Storage  
  - **3x3 grid:** Crafting area (drop items here)  
  - **Buildings tab:** Logs, extractors, etc. Press `Z` to place  
  - **Weapons tab:** Iron, gold, and diamond swords  
  - **Armour tab:** One piece per tier (iron/gold/diamond)  

- **Mineral Extractors:**  
  - 3 Tiers:  
	- **T1:** Coal, Iron  
	- **T2:** Coal, Iron, Gold  
	- **T3:** Coal, Iron, Gold, Diamonds  
  - Place them in the world and fuel with coal or logs.  

- **Soulyard:**  
  - You’re summoned at midnight to collect souls.  
  - Fight waves of skeletons, goblins, and zombies.  
  - Kill all to return to the overworld.  

- **Enemies:**  
  - Chase and attack you  
  - After attacking, they’re dazed—**exploit this!**

---

## CRAFTING RECIPES

---

### Stick  
**Recipe:** Two wood on top-left and middle-left  
Produces 4 sticks  
![Stick Recipe](https://img.itch.zone/aW1nLzIyMjU1MjY5LnBuZw==/original/%2FXMpQp.png)

---

### Swords  
**Recipe:**  
- Stick in bottom-middle  
- Two minerals (iron/gold/diamond) above it  
Produces the corresponding sword  
![Swords](https://img.itch.zone/aW1nLzIyMjU1MjkxLnBuZw==/original/dmn7xP.png)

---

### Armours  
**Recipe:**  
- 18 iron/gold/diamond  
- Spread evenly  
Produces corresponding armour  
![Armours](https://img.itch.zone/aW1nLzIyMjU1Mjk1LnBuZw==/original/tq3mcY.png)

---

### Tier 1 Mineral Extractor  
**Recipe:**  
- 1 Log surrounded by 8 stone  
![Tier 1 Extractor](https://img.itch.zone/aW1nLzIyMjU1Mjk5LnBuZw==/original/GfSkkU.png)

---

### Tier 2 Mineral Extractor  
**Recipe:**  
- Top: 5 coal  
- Bottom: 5 stone  
- Left & Right: 2 iron  
- Center: 1 Tier 1 Extractor  
![Tier 2 Extractor](https://img.itch.zone/aW1nLzIyMjU1MzA4LnBuZw==/original/SxR2jX.png)

---

### Tier 3 Mineral Extractor  
**Recipe:**  
This one's complex (5 gold, 5 iron, coal, rocks, etc.)  
See image for layout:  
![Tier 3 Extractor](https://img.itch.zone/aW1nLzIyMjU1MzE3LnBuZw==/original/R5sndJ.png)

---

### Bread  
**Recipe:**  
- 3 wheat in the middle row  
![Bread](https://img.itch.zone/aW1nLzIyMjU1MzI3LnBuZw==/original/Vdg%2BoN.png)
