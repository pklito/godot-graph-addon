
Built for Godot 4.8
This is a godot extension that visualizes nodes and allows you to easily make connected non-directed graphs.
<img width="480" height="262" alt="godot editor" src="https://github.com/user-attachments/assets/01226574-93ee-4ada-8817-7495d6337f5f" />
## Bidirectional spacial graph editor
Experimental godot extention for traversable path-tied maps.
This project has a simple character controller that moves on a predefined graph.
<img width="1335" height="796" alt="image" src="https://github.com/user-attachments/assets/f0e31e58-557f-4c14-b808-5af69a14bcfe" />

## Usage
Create a Location node from the regular 'add child node' menu.
Selecting a Location node will show three buttons to the spacial editor menu (the bar on top of the edit screen):  
1. **Connect**: Selecting 2 or more Locations each of them to eachother (fully connected graph).
2. **Disconnect**: Selecting a single node disconnects all of it's neighbors from it. Selecting multiple nodes only disconnects them from eachother.
3. **New**: Create a point that is connected to all of the current selection as is initialized at the COM of the selected nodes.

Each Location maintains an attribute `Neighbors`, which points to all the connected locations. These connections are bi-directional.
