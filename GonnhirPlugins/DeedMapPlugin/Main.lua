import "Turbine";
import "Turbine.UI";
import "Turbine.UI.Lotro";
import "GonnhirPlugins.DeedMapPlugin";

STOP_EDIT_TEXT = "Stop";

debug_window = Turbine.UI.Window();
debug_window:SetPosition( 0, 0 );
debug_window:SetSize( 100, 100 );
debug_window:SetVisible( false );
test_qs = Turbine.UI.Lotro.Quickslot(); -- for getting skill ids
test_qs:SetParent( debug_window );
test_qs:SetPosition( 0, 0 );
test_qs.ShortcutChanged = function( sender, args )
    Turbine.Shell.WriteLine( test_qs:GetShortcut():GetData() );
    test_qs:SetShortcut( Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Undefined, "" ) );
end

function BgAdjustedGetMousePosition() -- get proper mouse click position for original img if stretching bg 
    local x,y = bg:GetMousePosition();
    x = ( data[current_area].width / bg_width ) * x;
    y = ( data[current_area].height / bg_height ) * y;
    return round( x, 0 ), round( y, 0 );
end

function handle_bg_click( sender, args )
    if args.Button == Turbine.UI.MouseButton.Left then
        -- local x,y;
        -- if adjusted then
        --     x,y = BgAdjustedGetMousePosition();
        -- else
        --     x,y = bg:GetMousePosition();
        -- end
        -- x = x - 5; -- adjust for image, - 5 for loc, - 30 for zoom, - 15 for travel
        -- y = y - 5;
        -- Turbine.Shell.WriteLine( "{" .. x .. ", " .. y .. "};" );
    elseif args.Button == Turbine.UI.MouseButton.Right and data[current_area].main_area ~= nil then
        changeArea( data[current_area].main_area );
    end
end

current_area = "Middle-earth";
width = data[current_area].width;
height = data[current_area].height;
window = Turbine.UI.Lotro.Window();
window:SetPosition( 0, 0 );
window:SetText( "Map" );
window:SetVisible( true );
window:Activate();
bg = Turbine.UI.Control();
bg:SetParent( window );
bg:SetPosition( 20, 35 );
bg.MouseClick = handle_bg_click;
bg_width = bg:GetWidth();
bg_height = bg:GetHeight(); -- these need to be changed manually if stretching
bg.MouseMove = function( sender, args )
    if data[current_area].coord_x_min == nil then
        coordsLabel:SetVisible( false );
        return;
    end
    local coord_x_min = data[current_area].coord_x_min;
    local coord_y_min = data[current_area].coord_y_min;
    local coord_x_max = data[current_area].coord_x_max;
    local coord_y_max = data[current_area].coord_y_max;
    local x,y = bg:GetMousePosition();
    coordsLabel:SetText( position_to_coords( x, y, bg_width - 1, bg_height - 1, coord_x_min, coord_y_min, coord_x_max, coord_y_max ) );
    coordsLabel:SetPosition( bg_width + 25, bg_height - 25 + 35 );
    coordsLabel:SetVisible( true );
end
infoLabel = Turbine.UI.Label();
infoLabel:SetParent( window );
infoLabel:SetFont( Turbine.UI.Lotro.Font.BookAntiqua20 );
infoLabel:SetWidth( 200 );
infoLabel:SetHeight( 800 );
coordsLabel = Turbine.UI.Label();
coordsLabel:SetParent( window );
coordsLabel:SetFont( Turbine.UI.Lotro.Font.BookAntiqua20 );
coordsLabel:SetWidth( 500 );
disp_width = Turbine.UI.Display.GetWidth();
disp_height = Turbine.UI.Display.GetHeight();
qs = Turbine.UI.Lotro.Quickslot(); -- the same quickslot is used, its position and skill is changed based on hovered button
qs:SetParent( window );
qs:SetZOrder( 10 );
qs:SetShortcut( Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Undefined, "" ) );
qs:SetSize( 0, 0 );
deedmap_cmd = Turbine.ShellCommand();
deedmap_cmd.Execute = function( sender, cmd, args )
    if args == "debug_window" then
        debug_window:SetVisible( not debug_window:IsVisible() );
        return;
    end
    window:SetVisible( not window:IsVisible() );
    if window:IsVisible() then window:Activate() end
end
Turbine.Shell.AddCommand( "deedmap", deedmap_cmd );
filterMenu = Turbine.UI.ContextMenu();
filterMenuItems = filterMenu:GetItems();
filterButton = Turbine.UI.Lotro.Button();
filterButton:SetSize( 50, 20 );
filterButton:SetText( "Filter" );
filterButton:SetParent( window );
filterButton.Click = function( sender, args )
    filterMenuX, filterMenuY = Turbine.UI.Display.GetMousePosition();
    filterMenu:ShowMenu();
end
areaMenu = Turbine.UI.ContextMenu();
areaMenuItems = areaMenu:GetItems();
areaButton = Turbine.UI.Lotro.Button();
areaButton:SetSize( 50, 20 );
areaButton:SetText( "Area" );
areaButton:SetParent( window );
areaButton.Click = function( sender, args ) areaMenu:ShowMenu() end

for i,area in pairs( data.areas ) do
    areaMenuItems:Add( Turbine.UI.MenuItem( area ) );
end
for i = 1, areaMenuItems:GetCount() do
    local item = areaMenuItems:Get( i );
    item.Click = function( sender, args )
        local area = item:GetText();
        changeArea( area );
    end
end

function showCustomizeWindow( sender, args )
    customizeWindow:SetVisible( true );
    customizeWindow:Activate();
end

editButton = Turbine.UI.Lotro.Button();
editButton:SetSize( 100, 20 );
editButton:SetText( "Customize" );
editButton:SetParent( window );
editButton.Click = showCustomizeWindow;
customizeWindow = Turbine.UI.Lotro.Window();
customizeWindow:SetSize( 300, 300 );
customizeWindow:SetPosition( disp_width / 2 - 150, disp_height / 2 - 150 );
customizeWindow:SetText( "Customize" );
customizeWindow:SetVisible( false );
skillsButton = Turbine.UI.Lotro.Button();
skillsButton:SetSize( 250, 20 );
skillsButton:SetText( "Change travel skills" );
skillsButton:SetParent( customizeWindow );
skillsButton:SetPosition( 25, 50 );
skillsButton.Click = function( sender, args )
    customizeWindow:SetVisible( false );

    if travel_buttons[current_area] == nil or #travel_buttons[current_area] < 1 then
        local alertMenu = Turbine.UI.ContextMenu();
        alertMenu:GetItems():Add( Turbine.UI.MenuItem( "There are no travel buttons in this area!" ) );
        alertMenu:ShowMenu();
    else
        for i,button in pairs( travel_buttons[current_area] ) do
            button.EnterEdit();
        end
        prompt.area = current_area; -- make sure area changing won't mess things
        prompt.type = "skill_edit";
        editButton:SetText( STOP_EDIT_TEXT );
        editButton.Click = function( sender, args )
            prompt:SetVisible( true );
            prompt:Activate();
            infoLabel:SetVisible( false );
        end
        infoLabel:SetText( "Change the skill associated with a travel button by dragging the skill to its quickslot" );
        infoLabel:SetVisible( true );
    end
end
travelsButton = Turbine.UI.Lotro.Button();
travelsButton:SetSize( 250, 20 );
travelsButton:SetText( "Add new travel buttons" );
travelsButton:SetParent( customizeWindow );
travelsButton:SetPosition( 25, 80 );
travelsButton.Click = function( sender, args )
    customizeWindow:SetVisible( false );
    temp_custom_travel_data = {};
    temp_qs_table = {}; -- used for deleting all temp quickslots when stopping editing
    local temp_length = 0;
    bg.MouseClick = function( sender, args )
        local x,y;
        if adjusted then
            x,y = BgAdjustedGetMousePosition();
        else
            x,y = bg:GetMousePosition();
        end
        local point = {x - 15, y - 15};
        local temp_qs = Turbine.UI.Lotro.Quickslot();
        temp_qs:SetParent( bg );
        temp_qs:SetPosition( x - 15, y - 15 );
        temp_qs:SetZOrder( 10 );
        temp_qs.ShortcutChanged = function( sender, args )
            local new_idx;
    
            if temp_length < 1 then -- idx continues from default data, length needs to be manually updated
                new_idx = #data[current_area].travel + 1; 
            else
                -- get the last index, as it isn't necessarily the same as number of elements
                for i,val in pairs( temp_custom_travel_data ) do
                    if new_idx == nil or i > new_idx then new_idx = i end
                end
                new_idx = new_idx + 1;
            end
            temp_custom_travel_data[new_idx] = {};
            temp_custom_travel_data[new_idx].point = point;
            temp_custom_travel_data[new_idx].skill = temp_qs:GetShortcut():GetData();
            temp_length = temp_length + 1;
        end
        temp_qs_table[#temp_qs_table + 1] = temp_qs;
    end
    prompt.area = current_area;
    prompt.type = "travel_button";
    editButton:SetText( STOP_EDIT_TEXT );
    editButton.Click = function( sender, args )
        prompt:SetVisible( true );
        prompt:Activate();
        infoLabel:SetVisible( false );
    end
    infoLabel:SetText( "Add new travel buttons to a location on the map by clicking, then dragging " ..
                       "the port skill for it to the appearing quickslot");
    infoLabel:SetVisible( true );
end
deleteTravelsButton = Turbine.UI.Lotro.Button();
deleteTravelsButton:SetSize( 250, 20 );
deleteTravelsButton:SetText( "Delete custom travel buttons" );
deleteTravelsButton:SetParent( customizeWindow );
deleteTravelsButton:SetPosition( 25, 110 );
deleteTravelsButton.Click = function( sender, args )
    customizeWindow:SetVisible( false );
    prompt.area = current_area;
    prompt.type = "travels_delete";
    prompt:SetVisible( true );
    prompt:Activate();
end
deleteSkillsButton = Turbine.UI.Lotro.Button();
deleteSkillsButton:SetSize( 250, 20 );
deleteSkillsButton:SetText( "Reset travel skills to default" );
deleteSkillsButton:SetParent( customizeWindow );
deleteSkillsButton:SetPosition( 25, 140 );
deleteSkillsButton.Click = function( sender, args )
    customizeWindow:SetVisible( false );
    prompt.area = current_area;
    prompt.type = "skills_delete";
    prompt:SetVisible( true );
    prompt:Activate();
end
customizeLabel = Turbine.UI.Label();
customizeLabel:SetSize( 250, 100 );
customizeLabel:SetFont( Turbine.UI.Lotro.Font.BookAntiqua20 );
customizeLabel:SetText( "Note: Deleting or resetting affects all buttons and skills in the displayed " .. 
                        "area. They require reloading the plugin to take effect" );
customizeLabel:SetParent( customizeWindow );
customizeLabel:SetPosition( 25, 170 );
prompt = Turbine.UI.Lotro.Window();
prompt:SetText( "!" );
prompt:SetSize( 100, 120 );
prompt:SetPosition( disp_width / 2 - 150, disp_height / 2 - 100 );
prompt:SetVisible( false );
prompt.label = Turbine.UI.Label();
prompt.label:SetParent( prompt );
prompt.label:SetFont( Turbine.UI.Lotro.Font.BookAntiqua20 );
prompt.label:SetText( "Save changes?" );
prompt.label:SetSize( 200, 25 );
prompt.label:SetPosition( 30, 40 );
prompt.ok = Turbine.UI.Lotro.Button();
prompt.ok:SetParent( prompt );
prompt.ok:SetText( "Ok" );
prompt.ok:SetSize( 20, 20 );
prompt.ok:SetPosition( 30, 70 );
prompt.ok.Click = function( sender, args )
    prompt:SetVisible( false );
    editButton:SetText( "Customize" );
    editButton.Click = showCustomizeWindow;
    if prompt.area == nil then return end

    if prompt.type == "skill_edit" then
        for i,button in pairs( travel_buttons[prompt.area] ) do
            button.ExitEdit();

            if custom_skill_data[prompt.area] == nil then
                custom_skill_data[prompt.area] = {};
            end
            custom_skill_data[prompt.area][button.idx] = button.skill;
        end
        Turbine.PluginData.Save( Turbine.DataScope.Character, "DeedMapPluginSkills", custom_skill_data );
    elseif prompt.type == "travel_button" then
        if data[prompt.area].travel == nil then
            data[prompt.area].travel = {};
        end
        if travel_buttons[prompt.area] == nil then
            travel_buttons[prompt.area] = {};
        end
        if custom_travel_data[prompt.area] == nil then
            custom_travel_data[prompt.area] = {};
        end
        for i,val in pairs( temp_qs_table ) do
            val:SetVisible( false );
            val = nil;
        end
        for i,val in pairs( temp_custom_travel_data ) do
            data[prompt.area].travel[i] = {};
            data[prompt.area].travel[i].skill = val.skill;
            data[prompt.area].travel[i].point = val.point;
            travel_buttons[prompt.area][i] = TravelButton( prompt.area, i, data, bg, window, qs );
            travel_buttons[prompt.area][i]:SetVisible( true );
            custom_travel_data[prompt.area][i] = {};
            custom_travel_data[prompt.area][i].skill = val.skill;
            custom_travel_data[prompt.area][i].point = val.point;
        end
        Turbine.PluginData.Save( Turbine.DataScope.Character, "DeedMapPluginTravels", custom_travel_data );
        bg.MouseClick = handle_bg_click;
    elseif prompt.type == "travels_delete" then
        for i,val in pairs( custom_travel_data[prompt.area] ) do
            custom_travel_data[prompt.area][i] = nil;

            if custom_skill_data[prompt.area] ~= nil and custom_skill_data[prompt.area][i] ~= nil then
                custom_skill_data[prompt.area][i] = nil;
            end
        end
        Turbine.PluginData.Save( Turbine.DataScope.Character, "DeedMapPluginTravels", custom_travel_data );
        Turbine.PluginData.Save( Turbine.DataScope.Character, "DeedMapPluginSkills", custom_skill_data );
    elseif prompt.type == "skills_delete" then
        for i,val in pairs( custom_skill_data[prompt.area] ) do
            custom_skill_data[prompt.area][i] = nil;
        end
        Turbine.PluginData.Save( Turbine.DataScope.Character, "DeedMapPluginSkills", custom_skill_data );
    end
end
prompt.no = Turbine.UI.Lotro.Button();
prompt.no:SetParent( prompt );
prompt.no:SetText( "No" );
prompt.no:SetSize( 20, 20 );
prompt.no:SetPosition( 80, 70 );
prompt.no.Click = function( sender, args )
    prompt:SetVisible( false );
    editButton:SetText( "Customize" );
    editButton.Click = showCustomizeWindow;
    if prompt.area == nil then return end
    
    if prompt.type == "skill_edit" then
        for i,button in pairs( travel_buttons[prompt.area] ) do
            button.ExitEdit();
            button.skill = data[prompt.area].travel[button.idx].skill;
        end
    elseif prompt.type == "travel_button" then
        for i,val in pairs( temp_qs_table ) do
            val:SetVisible( false );
            val = nil;
        end
        bg.MouseClick = handle_bg_click;
    end
end
checkBox = Turbine.UI.Lotro.CheckBox();
checkBox:SetParent( window );
checkBox:SetText( " Stretch map to max size" );
checkBox:SetWidth( 220 );
checkBox.CheckedChanged = function( sender, args ) changeArea( current_area ) end

function set_filtering( item, new_val )
    item:SetChecked( new_val );

    for i,button in pairs( loc_buttons[current_area] ) do
        if button.info.type == item:GetText() or button.info.sub_type == item:GetText() then
            button:SetVisible( new_val );
        end
    end
    if filterMenuX ~= nil and filterMenuY ~= nil then
        filterMenu:ShowMenuAt( filterMenuX, filterMenuY ); -- menu auto closes, workaround for keeping it visible
    end
end

function changeArea( area )
    if editButton:GetText() == STOP_EDIT_TEXT then
        prompt:SetVisible( true );
        prompt:Activate();
        infoLabel:SetVisible( false );
        return;
    end
    width = data[area].width;
    height = data[area].height;
    bg_width = width;
    bg_height = height;
    window:SetSize( width + 40 + 220, height + 57 );
    bg:SetBackground( data[area].map );
    bg:SetStretchMode( 0 );
    bg:SetSize( bg_width, bg_height );
    bg:SetPosition( 20, 35 );
    local window_width = window:GetWidth();
    local window_height = window:GetHeight();

    if window_width > disp_width or window_height > disp_height or checkBox:IsChecked() then
        local ratio = window_width / window_height;
        local disp_ratio = disp_width / disp_height;

        if disp_ratio < ratio then 
            local new_height = (disp_width / window_width) * window_height;
            window:SetSize( disp_width, new_height );
        else
            local new_width = (disp_height / window_height) * window_width;
            window:SetSize( new_width, disp_height );
        end
        adjusted = true;
        window_width = window:GetWidth();
        window_height = window:GetHeight();
        bg_width = window_width - 40 - 220;
        bg_height = window_height - 57;
        window:SetPosition( 0, 0 );
        bg:SetStretchMode( 1 );
        bg:SetSize( bg_width, bg_height );
        filterButton:SetPosition( window_width - 220, 35 + 20 );
        areaButton:SetPosition( window_width - 220 + 50, 35 + 20 );
        editButton:SetPosition( window_width - 220 + 50 + 50, 35 + 20 );
        checkBox:SetPosition( window_width - 220, 35 + 50 );
        infoLabel:SetPosition( window_width - 220, 35 + 100 );
    else
        adjusted = false;
        filterButton:SetPosition( width + 20 + 20, 35 + 20 );
        areaButton:SetPosition( width + 20 + 20 + 50, 35 + 20 );
        editButton:SetPosition( width + 20 + 20 + 50 + 50, 35 + 20 );
        checkBox:SetPosition( width + 20 + 20, 35 + 50 );
        infoLabel:SetPosition( width + 20 + 20, 35 + 100 );
    end
    for i,button in pairs( loc_buttons[current_area] ) do
        button:SetVisible( false );
    end
    for i,button in pairs( zoom_buttons[current_area] ) do
        button:SetVisible( false );
    end
    for i,button in pairs( travel_buttons[current_area] ) do
        button:SetVisible( false );
    end
    current_area = area;

    for i,button in pairs( loc_buttons[current_area] ) do
        button:SetVisible( true );
    end
    for i,button in pairs( zoom_buttons[current_area] ) do
        button:SetVisible( true );
    end
    for i,button in pairs( travel_buttons[current_area] ) do
        button:SetVisible( true );
    end
    filterMenuItems:Clear();
    filterMenuItems:Add( Turbine.UI.MenuItem( "Select All" ) );
    filterMenuItems:Add( Turbine.UI.MenuItem( "Clear All" ) );
    filterMenuItems:Get( 1 ).Click = function( sender, args )
        for i = 3, filterMenuItems:GetCount() do
            local item = filterMenuItems:Get( i );
            set_filtering( item, true )
        end
    end
    filterMenuItems:Get( 2 ).Click = function( sender, args )
        for i = 3, filterMenuItems:GetCount() do
            local item = filterMenuItems:Get( i );
            set_filtering( item, false )
        end
    end
    for i,type in pairs( data.types ) do
        filterMenuItems:Add( Turbine.UI.MenuItem( type ) );
    end
    for i,type in pairs( data[current_area].sub_types ) do
        filterMenuItems:Add( Turbine.UI.MenuItem( type ) );
    end
    for i = 3, filterMenuItems:GetCount() do
        local item = filterMenuItems:Get( i );
        item:SetChecked( true );
        item.Click = function( sender, args )
            new_val = not item:IsChecked();
            set_filtering( item, new_val )
        end
    end
end

-- TODO maybe later don't load all at once

all_areas = {};
loc_buttons = {};
zoom_buttons = {};
travel_buttons = {};

for key,val in pairs( data ) do
    if key ~= "areas" and key ~= "types" then
        all_areas[#all_areas + 1] = key;
    end
end
for i,area in pairs( all_areas ) do
    loc_buttons[area] = {};

    for j,info in pairs( data[area] ) do
        if type(j) == "number" then -- if index is a number, it contains info for a button
            loc_buttons[area][j] = LocButton( area, j, data, bg, infoLabel );
            loc_buttons[area][j]:SetVisible( false );
        end
    end
end
for i,area in pairs( all_areas ) do
    zoom_buttons[area] = {};

    if data[area].zoom ~= nil then
        for j,info in pairs( data[area].zoom ) do
            zoom_buttons[area][j] = ZoomButton( info.area, info.point, bg, changeArea );
            zoom_buttons[area][j]:SetVisible( false );
        end
    end
end
for i,area in pairs( all_areas ) do
    travel_buttons[area] = {};
    
    if data[area].travel ~= nil then
        for j,info in pairs( data[area].travel ) do
            travel_buttons[area][j] = TravelButton( area, j, data, bg, window, qs );
            travel_buttons[area][j]:SetVisible( false );
        end
    end
end

custom_travel_data = Turbine.PluginData.Load( Turbine.DataScope.Character, "DeedMapPluginTravels" );

if custom_travel_data ~= nil then
    function load_travels()
        for area,area_info in pairs( custom_travel_data ) do
            for i,travel_info in pairs( area_info ) do 
                if data[area].travel == nil then
                    data[area].travel = {};
                end
                if travel_buttons[area] == nil then
                    travel_buttons[area] = {};
                end
                data[area].travel[i] = {}; -- saved indexes should already be continuing properly from data
                data[area].travel[i].skill = travel_info.skill;
                data[area].travel[i].point = travel_info.point;
                travel_buttons[area][i] = TravelButton( area, i, data, bg, window, qs );
                travel_buttons[area][i]:SetVisible( false );
            end
        end
    end
    pcall( load_travels );
else
    custom_travel_data = {};
end

custom_skill_data = Turbine.PluginData.Load( Turbine.DataScope.Character, "DeedMapPluginSkills" );

if custom_skill_data ~= nil then
    function load_skills()
        for area,info in pairs( custom_skill_data ) do
            for i,skill in pairs( info ) do
                if travel_buttons[area] ~= nil and travel_buttons[area][i] ~= nil then
                    travel_buttons[area][i].skill = skill;
                end
            end
        end
    end
    pcall( load_skills );
else 
    custom_skill_data = {}
end

changeArea( current_area );
