--!strict
--!native
--!optimize 2

return function(statement: any, errorMessage: string?): ()
	if not statement then
		error(`Kiy4ku's Ragdoll Service: {errorMessage}`, 2)
	end
end
