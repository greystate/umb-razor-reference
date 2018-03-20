do ->
	components = document.querySelector '.components'
	if components?
		items = (Array.from components.querySelectorAll '.component').sort (a, b) => a.dataset.title > b.dataset.title
		tocElement = document.createElement 'section'
		tocElement.classList.add 'components-toc'
		entries = [ '<ul>' ]
		for component in items
			componentID = component.getAttribute 'id' 
			componentName = component.dataset.title
			componentLink = componentID ? componentName.replace /\s+/g, '-'
			entries.push "<li><a href=\"##{componentLink}\">#{componentName}</a></li>"
			component.setAttribute 'id', componentLink unless componentID?
		
		entries.push '</ul>'
		tocElement.innerHTML = entries.join '\n'
		components.appendChild tocElement

