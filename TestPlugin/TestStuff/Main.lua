import "Turbine.UI";
import "Turbine.UI.Lotro";
import "TestPlugin.TestStuff";

current_area = "Bree-land"; -- use as default
prev_areas = {};
width = data[current_area]["width"];
height = data[current_area]["height"];
window = Turbine.UI.Lotro.Window();
window:SetPosition( 0, 0 );
window:SetText( "Map" );
window:SetVisible( true );
window:Activate();
bg = Turbine.UI.Control();
bg:SetParent( window );
bg:SetPosition( 20, 35 );
infoLabel = Turbine.UI.Label();
infoLabel:SetParent( window );
coordsLabel = Turbine.UI.Label();
coordsLabel:SetParent( window );
disp_width = Turbine.UI.Display.GetWidth();
disp_height = Turbine.UI.Display.GetHeight();

------------------

-- for developing

bg.MouseClick = function( sender, args )
    local x,y = bg:GetMousePosition();
    x = x - 5; -- adjust for image
    y = y - 5;
    Turbine.Shell.WriteLine( "{" .. x .. ", " .. y .. "};" );
end

---------------

function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0);
    return math.floor(num * mult + 0.5) / mult;
end

-- mins in top left, maxes in bottom right, positions are numbers, coords strings in format "74.9W", "113.1S" etc

function positionToCoords( pos_x, pos_y, pos_x_max, pos_y_max, coord_x_min, coord_y_min, coord_x_max, coord_y_max )
    local side_x_min = coord_x_min:sub( -1 );
    local side_y_min = coord_y_min:sub( -1 );
    local side_x_max = coord_x_max:sub( -1 );
    local side_y_max = coord_y_max:sub( -1 );
    local coord_x_min = tonumber( coord_x_min:sub( 1, -2 ) );
    local coord_y_min = tonumber( coord_y_min:sub( 1, -2 ) );
    local coord_x_max = tonumber( coord_x_max:sub( 1, -2 ) );
    local coord_y_max = tonumber( coord_y_max:sub( 1, -2 ) );
    local relative_dist_x = pos_x / pos_x_max; -- assume min positions of 0, 0
    local relative_dist_y = pos_y / pos_y_max;

    if side_x_min == "W" and side_x_max == "W" then
        local coord_x_span = coord_x_min - coord_x_max;
        local coord_x = coord_x_min - relative_dist_x * coord_x_span;
        local side_x = "W";
    elseif side_x_min == "E" and side_x_max == "E" then
        local coord_x_span = coord_x_max - coord_x_min;
        local coord_x = coord_x_min + relative_dist_x * coord_x_span;
        local side_x = "E";
    elseif side_x_min == "W" and side_x_max == "E" then
        local coord_x_span = coord_x_max + coord_x_min;
        local coord_x = coord_x_min - relative_dist_x * coord_x_span;

        if coord_x < 0 then
            coord_x = -coord_x;
            local side_x = "E";
        else
            local side_x = "W";
        end
    end

    if side_y_min == "N" and side_y_max == "N" then
        local coord_y_span = coord_y_min - coord_y_max;
        local coord_y = coord_y_min - relative_dist_y * coord_y_span;
        local side_y = "N";
    elseif side_y_min == "S" and side_y_max == "S" then
        local coord_y_span = coord_y_max - coord_y_min;
        local coord_y = coord_y_min + relative_dist_y * coord_y_span;
        local side_y = "S";
    elseif side_y_min == "N" and side_y_max == "S" then
        local coord_y_span = coord_y_max + coord_y_min;
        local coord_y = coord_y_min - relative_dist_y * coord_y_span;

        if coord_y < 0 then
            coord_y = -coord_y;
            local side_y = "S";
        else
            local side_y = "N";
        end
    end

    if side_x == nil or side_y == nil then return "" end
    coord_x = tostring( round( coord_x, 1 ) ) .. side_x;
    coord_y = tostring( round( coord_y, 1 ) ) .. side_y;
    return coord_y .. " " .. coord_x;
end

bg_width = bg:GetWidth();
bg_height = bg:GetHeight(); -- these need to be changed manually if stretching

bg.MouseMove = function(sender, args)
    if data[current_area]["coord_x_min"] == nil then
        coordsLabel:SetVisible( false );
        return;
    end
    
    local coord_x_min = data[current_area]["coord_x_min"];
    local coord_y_min = data[current_area]["coord_y_min"];
    local coord_x_max = data[current_area]["coord_x_max"];
    local coord_y_max = data[current_area]["coord_y_max"];
    local x,y = bg:GetMousePosition();
    coordsLabel:SetFont( Turbine.UI.Lotro.Font.BookAntiqua20 );
    coordsLabel:SetText( positionToCoords( x, y, bg_width - 1, bg_height - 1, coord_x_min, coord_y_min, coord_x_max, coord_y_max ) );
    coordsLabel:SetWidth( 500 );
    coordsLabel:SetPosition( bg_width + 25, bg_height - 25 + 35 );
    coordsLabel:SetVisible( true );
end

---------------

cmd = Turbine.ShellCommand();
cmd.Execute = function( sender, cmd, args )
    window:SetVisible( not window:IsVisible() );
    if window:IsVisible() then window:Activate() end
end
Turbine.Shell.AddCommand("deedmap", cmd);

---------------

LocButton = class( Turbine.UI.Button );

function LocButton:Constructor( area, idx )
    Turbine.UI.Button.Constructor( self );
    self.selected = false;
    self.area = area;
    self.idx = idx;
    self.label = Turbine.UI.Label();
    self.label:SetBackColor( Turbine.UI.Color( 0, 0, 0 ) );
    self.label:SetFont( Turbine.UI.Lotro.Font.BookAntiqua20 );
    self:SetSize( 16, 16 );
    self:SetBackground( 0x410f34f1 );
    self:SetBlendMode( Turbine.UI.BlendMode.Overlay );
    self:SetParent( bg );
    self.label:SetParent( bg );
    self.label:SetVisible( false );
    self.info = data[area][idx];
    self:SetPosition( unpack(self.info["point"]) );
    self.MouseEnter = function(sender, args)
        x,y = unpack(self.info["point"]);
        self.label:SetText( self.info["text"] );
        self.label:SetPosition( x + 20, y - 20 );
        self.label:SetWidth( self.label:GetTextLength() * 8 );
        self.label:SetHeight( 25 );
        self.label:SetVisible( true );
        self.label:SetZOrder( 10 ); -- show on top
        self.label:SetStretchMode( 1 ); -- renders outside bg bounds
    end
    self.MouseLeave = function(sender, args)
        self.label:SetVisible( false );
    end
    self.Click = function( sender, args )
        changeSelection( self.area, self.idx, self.selected );
        infoLabel:SetFont( Turbine.UI.Lotro.Font.BookAntiqua20 );
        infoLabel:SetText( self.info["desc"] );
        infoLabel:SetWidth( 200 );
        infoLabel:SetHeight( 800 );
        infoLabel:SetVisible( self.selected );
    end
end

ZoomButton = class( Turbine.UI.Button );

function ZoomButton:Constructor( area, point )
    Turbine.UI.Button.Constructor( self );
    self:SetBackground( 0x410081a2 );
    self:SetSize( 63, 63 );
    self:SetBlendMode( Turbine.UI.BlendMode.Overlay );
    self:SetParent( bg );
    self:SetPosition( unpack( point ) );
    self.area = area;
    self.MouseEnter = function(sender, args)
        self:SetBlendMode( Turbine.UI.BlendMode.Multiply );
    end
    self.MouseLeave = function(sender, args)
        self:SetBlendMode( Turbine.UI.BlendMode.Overlay );
    end
    self.Click = function( sender, args )
        changeArea( self.area );
    end
end

changeSelection = function( area, idx, remove_selection )
    for i,button in pairs( loc_buttons[area] ) do
        if remove_selection or i ~= idx then
            button:SetBackground( 0x410f34f1 );
            button.selected = false;
        else
            button:SetBackground( 0x410d7856 );
            button.selected = true;
        end
    end
end

------------------

-- TODO maybe later don't load all at once

loc_buttons = {};

for i,area in pairs( data["all_areas"] ) do
    loc_buttons[area] = {};

    for j,info in pairs(data[area]) do
        if type(j) == "number" then -- if index is a number, it contains info for a button
            loc_buttons[area][j] = LocButton( area, j );
            loc_buttons[area][j]:SetVisible( false );
        end
    end
end

for i,button in pairs( loc_buttons[current_area] ) do
    button:SetVisible( true );
end

zoom_buttons = {};

for i,area in pairs( data["all_areas"] ) do
    zoom_buttons[area] = {};

    if data[area]["zoom"] ~= nil then
        for j,info in pairs(data[area]["zoom"]) do
            zoom_buttons[area][j] = ZoomButton( info["area"], info["point"] );
            zoom_buttons[area][j]:SetVisible( false );
        end
    end
end

for i,button in pairs( zoom_buttons[current_area] ) do
    button:SetVisible( true );
end

---------------

filterButton = Turbine.UI.Lotro.Button();
filterButton:SetSize( 50, 20 );
filterButton:SetText( "Filter" );
filterButton:SetParent( window );
filterButton.Click = function( sender, args )
    filterMenu:ShowMenu();
end
filterMenu = Turbine.UI.ContextMenu();
filterMenuItems = filterMenu:GetItems();

areaButton = Turbine.UI.Lotro.Button();
areaButton:SetSize( 50, 20 );
areaButton:SetText( "Area" );
areaButton:SetParent( window );
areaButton.Click = function( sender, args )
    areaMenu:ShowMenu();
end
areaMenu = Turbine.UI.ContextMenu();
areaMenuItems = areaMenu:GetItems();

for i,area in pairs( data["areas"] ) do
    areaMenuItems:Add( Turbine.UI.MenuItem( area ) );
end

for i = 1, areaMenuItems:GetCount() do
    local item = areaMenuItems:Get( i );
    item.Click = function( sender, args )
        local area = item:GetText();
        changeArea( area );
    end
end

prevButton = Turbine.UI.Lotro.Button();
prevButton:SetSize( 50, 20 );
prevButton:SetText( "Back" );
prevButton:SetParent( window );
prevButton.Click = function( sender, args )
    if next(prev_areas) == nil then return end
    local to_area = prev_areas[#prev_areas];
    table.remove( prev_areas );
    changeArea( to_area, true );
end

-------------

function changeArea( area, no_insert )
    width = data[area]["width"];
    height = data[area]["height"];
    bg_width = width;
    bg_height = height;
    window:SetSize( width + 40 + 220, height + 57 );
    bg:SetBackground( data[area]["map"] );
    bg:SetStretchMode( 0 );
    bg:SetSize( bg_width, bg_height );
    bg:SetPosition( 20, 35 );
    
    ----------

    local adjusted = false;

    if window:GetWidth() > disp_width then
        window:SetWidth( disp_width );
        adjusted = true;
    end
    
    if window:GetHeight() > disp_height then
        window:SetHeight( disp_height );
        adjusted = true;
    end

    if adjusted then
        local window_width = window:GetWidth();
        bg_width = window_width - 40 - 220;
        bg_height = window:GetHeight() - 57;
        window:SetPosition( 0, 0 );
        bg:SetStretchMode( 1 );
        bg:SetSize( bg_width, bg_height );
        filterButton:SetPosition( window_width - 220, 35 + 20 );
        areaButton:SetPosition( window_width - 220 + 70, 35 + 20 );
        prevButton:SetPosition( window_width - 220 + 70 + 70, 35 + 20 );
        infoLabel:SetPosition( window_width - 220, 35 + 100 );
    else
        filterButton:SetPosition( width + 20 + 20, 35 + 20 );
        areaButton:SetPosition( width + 20 + 20 + 70, 35 + 20 );
        prevButton:SetPosition( width + 20 + 20 + 70 + 70, 35 + 20 );
        infoLabel:SetPosition( width + 20 + 20, 35 + 100 );
    end

    ---------

    local prev_area = current_area;
    if no_insert == nil then table.insert( prev_areas, prev_area ) end
    current_area = area;

    for i,button in pairs( loc_buttons[prev_area] ) do
        button:SetVisible( false );
    end

    for i,button in pairs( zoom_buttons[prev_area] ) do
        button:SetVisible( false );
    end

    for i,button in pairs( loc_buttons[current_area] ) do
        button:SetVisible( true );
    end

    for i,button in pairs( zoom_buttons[current_area] ) do
        button:SetVisible( true );
    end

    ---------

    filterMenuItems:Clear();
    filterMenuItems:Add( Turbine.UI.MenuItem( "Select All" ) );
    filterMenuItems:Add( Turbine.UI.MenuItem( "Clear All" ) );
    filterMenuItems:Get( 1 ).Click = function( sender, args )
        for i = 3, filterMenuItems:GetCount() do
            local item = filterMenuItems:Get( i );
            item:SetChecked( true );
    
            for i,button in pairs( loc_buttons[current_area] ) do
                if button.info["type"] == item:GetText() or button.info["sub_type"] == item:GetText() then
                    button:SetVisible( true );
                end
            end
        end
    end
    filterMenuItems:Get( 2 ).Click = function( sender, args )
        for i = 3, filterMenuItems:GetCount() do
            local item = filterMenuItems:Get( i );
            item:SetChecked( false );
    
            for i,button in pairs( loc_buttons[current_area] ) do
                if button.info["type"] == item:GetText() or button.info["sub_type"] == item:GetText() then
                    button:SetVisible( false );
                end
            end
        end
    end

    for i,type in pairs( data["types"] ) do
        filterMenuItems:Add( Turbine.UI.MenuItem( type ) );
    end

    for i,type in pairs( data[current_area]["sub_types"] ) do
        filterMenuItems:Add( Turbine.UI.MenuItem( type ) );
    end

    for i = 3, filterMenuItems:GetCount() do
        local item = filterMenuItems:Get( i );
        item:SetChecked( true );
        item.Click = function( sender, args )
            new_val = not item:IsChecked();
            item:SetChecked( new_val );
    
            for i,button in pairs( loc_buttons[current_area] ) do
                if button.info["type"] == item:GetText() or button.info["sub_type"] == item:GetText() then
                    button:SetVisible( new_val );
                end
            end
        end
    end
end

changeArea( current_area );
