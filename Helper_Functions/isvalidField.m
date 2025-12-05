% Helper function to safely test if a field exists and is valid
function tf = isvalidField(app, propName)
    tf = isprop(app, propName) && ~isempty(app.(propName)) && isvalid(app.(propName));
end