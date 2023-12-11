protocol ConfigurableViewProtocol {
    associatedtype ViewModel
    
    func configure(with viewModel: ViewModel)
}
