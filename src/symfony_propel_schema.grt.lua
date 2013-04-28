--
-- SymfonyPropelSchema 1.06
--
-- Mysql Workbench plugin for processing schema into symfony's yml format.
--
-- Copyright Jason Rowe <jason.rowe@milestoneip.com> / MilestoneIP 2008 - Milestone IP LTD <www.milestoneip.com>
-- Copyright (c) 2010-2013 Toha <tohenk@yahoo.com>
--
-- Version 1.06 -- April 28, 2013
-- * Map TINYINT(1) as BOOLEAN
--
-- Version 1.05 -- Dec 17, 2010
-- * Plugin renamed from SymfonyPropelSchemaExport to SymfonyPropelSchema
-- * Added mapping for BLOB, MEDIUMBLOB, LONGBLOB as VARBINARY, VARBINARY, LONGVARBINARY
-- * Fixed foreign keys for multi columns
--
-- This plugin was inspired by the great work in the PropelExport plugin written by
-- Daniel Haas <daniel.haas@cn-consult.eu> Thank you Daniel, i learned lua from deciphering your source code.
--
-- I have tried to make this work as generically as possible and produce the most short hand syntax
-- available in the schema yml files.
--
-- Notes:
-- automatic primary keys. Whenever an integer primary key is used without any other 'modifiers' we use the ~ short hand syntax.
-- automatic created/updated columns. whenever these columns are added to the schema we use the ~ short hand syntax.
-- we use the shorthand syntax for foreign keys adding foreignTable, foreignReference & onDelete into the actual column
--
-- please report any bugs to <jason.rowe@milestoneip.com>.
-- please report any change requests to <jason.rowe@milestoneip.com>
--
-- For more information about symfony, please goto <http://www.symfony-project.org>
--
--
-- The module is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
-- without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
-- See the GNU General Public License for more details.
--
-- We deliver this software for free, and expect no return other than to improve the usefulness of
-- symfony together with mysql workshop.
--
-- Support:
-- Please note that while i will try my best to answer your queries and emails, I work full time on other
-- projects and cannot answer emails immediately.
--
-- I hope you find the software useful and it speeds up development for you.
--
-- Jason Rowe 2008

function getModuleInfo()
	return {
		name= "SymfonyPropelSchema",
		author= "MySQL AB.",
		version= "1.06",
		implements= "PluginInterface",
		functions= {
			"getPluginInfo:l<o@app.Plugin>:",
			"exportToClipboard:i:o@db.Catalog",
			"exportToFile:i:o@db.Catalog"
		}
	}
end


-- helper function to create a descriptor for an argument of a specific type of object
function objectPluginInput(type)
	return grtV.newObj("app.PluginObjectInput", {objectStructName= type})
end

function getPluginInfo()
	-- create the list of plugins that this module exports
	local l
	local plugin

	-- create the list of plugins that this module exports
	l= grtV.newList("object", "app.Plugin")

	plugin= grtV.newObj("app.Plugin", {
		name= "wb.SymfonyPropelSchema.exportToClipboard",
		caption= "Symfony Propel Schema > To Clipboard (New Schema)",
		moduleName= "SymfonyPropelSchema",
		pluginType= "normal",
		moduleFunctionName= "exportToClipboard",
		inputValues= {objectPluginInput("db.Catalog")},
		rating= 100,
		showProgress= 0,
		groups= {"Catalog/Utilities", "Menu/Catalog"}
	})
	-- fixup owner
	plugin.inputValues[1].owner= plugin

	-- add to the list of plugins
	grtV.insert(l, plugin)

	plugin= grtV.newObj("app.Plugin", {
		name= "wb.SymfonyPropelSchema.exportToFile",
		caption= "Symfony Propel Schema > To File (New Schema)",
		moduleName= "SymfonyPropelSchema",
		pluginType= "normal",
		moduleFunctionName= "exportToFile",
		inputValues= {objectPluginInput("db.Catalog")},
		rating= 100,
		showProgress= 0,
		groups= {"Catalog/Utilities", "Menu/Catalog"}
	})
	-- fixup owner
	plugin.inputValues[1].owner= plugin

	-- add to the list of plugins
	grtV.insert(l, plugin)

	return l
end

--
-- object definitions
--
sfTableColumn = {}
function sfTableColumn:new() -- The constructor
	local object = {
		name = nil,
		required = false,
		primaryKey = false,
		autoIncrement = false,
		type = nil,
		length = 0,
		length2 = 0,
		default = nil,
		defaultExpr = nil,
		sequence = nil,
		index = false,
		foreignTable = nil,
		foreignReference = nil,
		onUpdate = nil,
		onDelete = nil,
		isCulture = false,
		description = nil,
	}
	setmetatable(object, {
		-- Overload the index event so that fields not present within the object are
		-- looked up in the prototype Vector table
		__index = sfTableColumn
	})

	return object
end

function sfTableColumn:printYml()
	if (self.name ~= nil) then
		-- self.name == "id" (only if the current type is integer - else we need to specifically specify the identifier.)
		if (self.name == "id" and self.type == "INTEGER") then
			return "~"
		end
		if (self.name == "created_at" or self.name == "created_on" or self.name == "updated_at" or self.name == "updated_on") then
			return "~"
		end
	end

	local defs = {}

	-- type
	table.insert(defs, "type: " .. string.lower(self.type))
	if (self.length > 0) then
		table.insert(defs, "size: " .. self.length)
	end
	if (self.length2 > 0) then
		table.insert(defs, "scale: " .. self.length2)
	end
	if (self.required == true) then
		table.insert(defs, "required: true")
	end
	if (self.primaryKey == true) then
		table.insert(defs, "primaryKey: true")
	end
	if (self.autoIncrement == true) then
		table.insert(defs, "autoIncrement: true")
	end
	if (self.default ~= nil) then
		table.insert(defs, "default: " .. self.default)
	end
	if (self.defaultExpr ~= nil) then
		table.insert(defs, "defaultExpr: " .. self.defaultExpr)
	end
	if (self.sequence ~= nil) then
		table.insert(defs, "sequence: " .. self.sequence)
	end
	if (self.index == true) then
		table.insert(defs, "index: true")
	end
	if (self.foreignTable ~= nil) then
		table.insert(defs, "foreignTable: " .. self.foreignTable)
	end
	if (self.foreignReference ~= nil) then
		table.insert(defs, "foreignReference: " .. self.foreignReference)
	end
	if (self.onUpdate ~= nil) then
		table.insert(defs, "onUpdate: " .. self.onUpdate)
	end
	if (self.onDelete ~= nil) then
		table.insert(defs, "onDelete: " .. self.onDelete)
	end
	if (self.description ~= nil) then
		table.insert(defs, "description: " .. self.description)
	end
	if (self.isCulture == true) then
		table.insert(defs, "isCulture: true")
	end

	return "{ " .. concat(defs) .. " }"
end

function sfTableColumn:convertDataType(column)
	if (column.simpleType ~= nil) then
		self:asPropelDataType(column.simpleType.name, column, true)
	else
		if (column.userType ~= nil) then
			if (false == self:asPropelDataType(column.userType.name, column, false)) then
				self:asPropelDataType(column.userType.actualType.name, column, true)
			end
		end
	end
end

function sfTableColumn:asPropelDataType(dataType, column, force)
	if (dataType == nil) then
		return false
	end
	self.type = nil
	if (dataType == "TINYINT" and column.precision == 1) then
		self.type = "BOOLEAN"
	end
	if (dataType == "INT" or dataType == "MEDIUMINT") then
		self.type = "INTEGER"
	end
	if (dataType == "TINYTEXT") then
		self.type = "VARCHAR"
		self.length = 255
	end
	if (dataType == "TEXT") then
		self.type = "LONGVARCHAR"
		self.length = 65535
	end
	if (dataType == "MEDIUMTEXT") then
		self.type = "CLOB"
		self.length = 16777215
	end
	if (dataType == "LONGTEXT") then
		self.type = "CLOB"
		self.length = 4294967295
	end
	if (dataType == "TINYBLOB") then
		self.type = "BINARY"
		self.length = 255
	end
	if (dataType == "BLOB") then
		self.type = "BINARY"
		self.length = 65535
	end
	if (dataType == "MEDIUMBLOB") then
		self.type = "VARBINARY"
		self.length = 16777215
	end
	if (dataType == "LONGBLOB") then
		self.type = "LONGVARBINARY"
		self.length = 4294967295
	end
	if (dataType == "DATETIME") then
		self.type = "TIMESTAMP"
	end
	if (dataType == "YEAR") then
		self.type = "SMALLINT"
	end
	if (dataType == "BOOL") then
		self.type = "BOOLEAN"
	end
	if (dataType == "DECIMAL") then
		self.type = "DECIMAL"
		self.length = column.precision
		self.length2 = column.scale
	end
	if (self.type == nil) then
		if (false == force) then
			return false
		else
			self.type = dataType
		end
	end

	return true
end

--
-- implementation
--

function exportToClipboard(cat)
	local yml = convertSchemaIntoSymfonyYml(cat)
	Workbench:copyToClipboard(yml)
	showMessage("Schema sucessfully copied to clipboard.\n")

	return 0
end

function exportToFile(cat)
	local yml = convertSchemaIntoSymfonyYml(cat)
	local q = true
	local regName = "SymfonyPropelSchema.Path"
	local filename

	if (cat.customData[regName] ~= nil) then
		q = false
		if (Workbench:confirm("Confirm?", "Do you want to overwrite previously exported file " .. cat.customData[regName] .. "?") == 1) then
			q = true
		end
	end

	if (q) then
		filename = Workbench:input('Please enter filename to export the symfony schema to?')
		if (filename ~= "")
		then
			-- Try to save the filepath for the next time:
			cat.customData[regName] = filename
		end
	end

	filename = cat.customData[regName]
	if (filename ~= "") then
		f = io.open(filename, "w")
		if (f ~= nil) then
			f.write(f, yml)
			f.close(f)
			print('\n > Symfony-Schema was exported to ' .. filename)
		else
			print('\n > Could not open file ' .. filename .. '!')
		end
	else
		print('\n > Symfony-Schema was NOT exported as no path was given!')
	end

	return 0
end

--
-- Base function for processing the mysql workbench model into symfonys yml format
--
function convertSchemaIntoSymfonyYml(cat)
	local schema
	local tbl
	local column
	local index
	local newline = "\n"
	local yml = {}
	local i, j, k, z, s
	local currentColumn
	local maxColumnLength = getLongestColumnLength(cat)
	local ordered = false

	-- determine minimum column length
	if (maxColumnLength < 18) then
		maxColumnLength = 18
	end
	maxColumnLength = maxColumnLength + 8 -- ident size for column

	if (Workbench:confirm("Confirm?", "Do you want the schema to be ordered by the tablename?") == 1) then
		ordered = true
	end

	-- new schema opening
	table.insert(yml, yamlValue("connection",      "propel",    maxColumnLength))
	table.insert(yml, yamlValue("defaultIdMethod", "native",    maxColumnLength))
	table.insert(yml, yamlValue("package",         "lib.model", maxColumnLength))
	table.insert(yml, "")
	table.insert(yml, yamlValue("classes"))

	-- multiple schemas
	for i = 1, grtV.getn(cat.schemata) do

		schema = cat.schemata[i]
		local tbls = listTables(schema.tables, ordered)

		-- multiple tables
		for j, tbl in pairs(tbls) do

			table.insert(yml, yamlValue(addTab(1) .. camelize(tbl.name)))
			table.insert(yml, yamlValue(addTab(2) .. "tableName", tbl.name, maxColumnLength))
			table.insert(yml, yamlValue(addTab(2) .. "columns"))

			for k = 1, grtV.getn(tbl.columns) do

				column = tbl.columns[k]

				currentColumn = nil
				currentColumn = sfTableColumn:new()
				currentColumn.name = column.name
				currentColumn:convertDataType(column)

				-- size
				if (column.length ~= nil) then
					if (column.length == -1) then
						currentColumn.length = 0
					else
						currentColumn.length = column.length
					end
				end

				-- required
				currentColumn.required = column.isNotNull == 1

				-- autoInc
				currentColumn.autoIncrement = column.autoIncrement == 1

				-- default value
				if (column.defaultValue ~= nil and column.defaultValue ~= "" and column.defaultValue ~= "NULL") then
					if (column.defaultValue ~= "CURRENT_TIMESTAMP") then
						currentColumn.default = column.defaultValue
					end
					currentColumn.defaultExpr = column.defaultValue
				end

				-- comment
				if (column.comment ~= "") then
					currentColumn.description = column.comment
				end

				-- primaryKey (now using index lookup)
				if (#tbl.indices > 0) then
					for z = 1, grtV.getn(tbl.indices) do
						index = tbl.indices[z]
						if (index.indexType == "PRIMARY") then
							for l = 1, grtV.getn(index.columns) do
								indexColumn = index.columns[l]
								if (indexColumn.referencedColumn ~= nil) then
									referencedColumn = indexColumn.referencedColumn
									if (referencedColumn.name == column.name) then
										currentColumn.primaryKey = true;
									end
								end
							end
						end
					end
				end

				-- foreign key
				if (#tbl.foreignKeys > 0) then
					for z = 1, grtV.getn(tbl.foreignKeys) do
						foreignKey = tbl.foreignKeys[z]
						if (#foreignKey.columns == 1) then
							-- foreign key definition as shorthand 
							foreignKeyColumn = foreignKey.columns[1]
							foreignKeyReferencedColumn = foreignKey.referencedColumns[1]
							if (foreignKeyColumn.name == column.name) then
								if (foreignKey.referencedTable ~= nil) then
									currentColumn.foreignTable = foreignKey.referencedTable.name
									currentColumn.foreignReference = foreignKeyReferencedColumn.name
								end

								if (foreignKey.deleteRule ~= "NO ACTION") then
									currentColumn.onDelete = string.lower(foreignKey.deleteRule)
								end
								if (foreignKey.updateRule ~= "NO ACTION") then
									currentColumn.onUpdate = string.lower(foreignKey.updateRule)
								end
							end
						end
					end
				end

				table.insert(yml, yamlValue(addTab(3) .. column.name, currentColumn:printYml(), maxColumnLength))
			end

			-- multi columns foreign keys
			-- fkey:
			--   foreignTable: table1
			--   onDelete: delete
			--   onUpdate: delete
			--   references:
			--     - { local: column1, foreign: column2 }
			--     - { local: column3, foreign: column4 }
			if (#tbl.foreignKeys > 0) then
				local included = false
				for z = 1, grtV.getn(tbl.foreignKeys) do
					if (#tbl.foreignKeys[z].columns > 1) then
						-- include header
						if (included == false) then
							table.insert(yml, yamlValue(addTab(2) .. "foreignKeys"))
							included = true
						end
						table.insert(yml, yamlValue(addTab(3) .. tbl.foreignKeys[z].name))
						table.insert(yml, yamlValue(addTab(4) .. "foreignTable", tbl.foreignKeys[z].referencedTable.name, maxColumnLength))
						if (tbl.foreignKeys[z].deleteRule ~= "NO ACTION") then
							table.insert(yml, yamlValue(addTab(4) .. "onDelete", string.lower(tbl.foreignKeys[z].deleteRule), maxColumnLength))
						end
						if (tbl.foreignKeys[z].updateRule ~= "NO ACTION") then
							table.insert(yml, yamlValue(addTab(4) .. "onUpdate", string.lower(tbl.foreignKeys[z].updateRule), maxColumnLength))
						end
						table.insert(yml, yamlValue(addTab(4) .. "references"))
						for l = 1, grtV.getn(tbl.foreignKeys[z].columns) do
							table.insert(yml, addTab(5) .. string.format("- { local: %s, foreign: %s }", tbl.foreignKeys[z].columns[l].name, tbl.foreignKeys[z].referencedColumns[l].name))
						end
					end
				end
			end

			-- indexes and uniques
			if (#tbl.indices > 0) then
				local k, v
				for k, v in pairs({indexes = "INDEX", uniques = "UNIQUE"}) do
					local included = false
					for z = 1, grtV.getn(tbl.indices) do
						index = tbl.indices[z]
						if (index.indexType == v) then
							-- include header
							if (included == false) then
								table.insert(yml, yamlValue(addTab(2) .. k))
								included = true
							end
							local lst = {}
							for l = 1, grtV.getn(index.columns) do
								column = index.columns[l]
								table.insert(lst, column.referencedColumn.name)
							end
							table.insert(yml, yamlValue(addTab(3) .. index.name, "[ " .. concat(lst) .. " ]", maxColumnLength))
						end
					end
				end
			end
		end
	end
	s = concat(yml, newline)

	return s
end

--
-- Find out how long the longest column in the whole schema is
--
function getLongestColumnLength(cat)
	local maxColumnLength = 0
	local schema
	local tbl
	local column
	local index

	for i = 1, grtV.getn(cat.schemata) do
		schema = cat.schemata[i]

		-- do table columns
		for j = 1, grtV.getn(schema.tables) do
			tbl = schema.tables[j]
			for k = 1, grtV.getn(tbl.columns) do
				column = tbl.columns[k]
				if(maxColumnLength < string.len(column.name)) then
					maxColumnLength = string.len(column.name)
				end
			end

			-- now check the length of indicies
			for m = 1, grtV.getn(tbl.indices) do
				index = tbl.indices[m]
				--if (index.indexType ~= "FOREIGN") then
					if(maxColumnLength < string.len(index.name)) then
						maxColumnLength = string.len(index.name)
					end
				--end
			end
		end
	end

	return maxColumnLength
end

--
-- Pad a string with a character to specified length
--
function padRight(s, length, padchar)
	local i
	if (string.len(s) >= length) then
		return s
	end
	i = length - string.len(s)

	return s .. string.rep(padchar, i)
end

--
-- Create a pair of yaml key and value
--
function yamlValue(key, value, size, newline)
	local s

	if (size == nil) then
		size = 0
	end
	s = key .. ":"
	if (value ~= nil) then
		if (string.sub(s, string.len(s), 1) ~= " ") then
			s = s .. " "
		end
		s = padRight(s, size, " ") .. value
	end
	if (newline) then
		s = s .. "\n"
	end

	return s
end

--
-- Camelize an lower_cased_and_underscored text
--
function camelize(s)
	local pos
	local tmp
	local cs = ""

	while true do
		pos = string.find(s, "_")
		if (pos == nil) then
			break
		end
		tmp = string.sub(s, 1, pos - 1)
		s = string.sub(s, pos + 1, string.len(s))
		cs = cs .. ucfirst(tmp)
	end
	cs = cs .. ucfirst(s)

	return cs
end

--
-- Ucfirst, upcase first character of words
--
function ucfirst(s)
	if (string.len(s) > 0) then
		s = string.upper(string.sub(s, 1, 1)) .. string.sub(s, 2, string.len(s))
	end

	return s
end

--
-- Add YAML indentation
--
function addTab(size)
	local s = ""
	if (size > 0) then
		s = string.rep(" ", size * 2)
	end

	return s
end

--
-- Concatenate an array into a string by a separator
--
function concat(a, sep)
	local s = ""

	-- default separator
	if (sep == nil) then
		sep = ", "
	end
	for k, v in ipairs(a) do
		if (s ~= "") then
			s = s .. sep
		end
		s = s .. v
	end

	return s
end

--
-- List tables as array 
--
function listTables(tables, sorted, f)
	local tbls = {}
	local i

	for i = 1, grtV.getn(tables) do
		if (sorted) then
			tbls[tables[i].name] = tables[i]
		else
			table.insert(tbls, tables[i])
		end
	end
	if (sorted) then
		tbls = sortTables(tbls, f)
	end

	return tbls
end

--
-- Sort table by table name
--
function sortTables(tables, f)
	local tbls = {}
	local keys = {}
	local i, j

	-- list keys
	for i, j in pairs(tables) do
		table.insert(keys, i)
	end

	-- sort keys
	table.sort(keys, f)

	-- order tables by keys
	for i, j in ipairs(keys) do
		table.insert(tbls, tables[j])    
	end

	return tbls
end

--
-- Show a message in a form
--
function showMessage(msg, caption)
	local f
	if (caption == nil) then
		caption = "Information"
	end
	f = "label;" .. msg
	v = grtV.newDict()

	return Forms:show_simple_form(caption, f, v)
end

-- EOF --