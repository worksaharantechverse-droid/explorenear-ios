import Combine
import CoreLocation
import MapKit
import UIKit

final class ExploreViewController: UIViewController, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate {
    private let viewModel: ExploreViewModel
    private var cancellables = Set<AnyCancellable>()

    private let chipScrollView = UIScrollView()
    private let chipStackView = UIStackView()
    private let fallbackBanner = UILabel()
    private let statusLabel = UILabel()
    private let mapView = MKMapView()
    private let tableView = UITableView()
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)

    init(viewModel: ExploreViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "ExploreNear"
        view.backgroundColor = .systemBackground

        configureChips()
        configureLabels()
        configureMap()
        configureTable()
        configureLayout()
        bindViewModel()
        render()
        viewModel.start()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.stop()
    }

    private func configureChips() {
        chipScrollView.translatesAutoresizingMaskIntoConstraints = false
        chipScrollView.showsHorizontalScrollIndicator = false
        chipScrollView.accessibilityIdentifier = "explore.categories"

        chipStackView.axis = .horizontal
        chipStackView.spacing = 8
        chipStackView.translatesAutoresizingMaskIntoConstraints = false

        for (index, category) in PlaceCategory.allCases.enumerated() {
            let button = UIButton(type: .system)
            var configuration = UIButton.Configuration.plain()
            configuration.title = category.title
            configuration.image = UIImage(systemName: category.symbol)
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
            button.configuration = configuration
            button.tag = index
            button.layer.cornerRadius = 16
            button.addTarget(self, action: #selector(categoryTapped(_:)), for: .touchUpInside)
            button.accessibilityIdentifier = "explore.category.\(category.rawValue)"
            chipStackView.addArrangedSubview(button)
        }

        chipScrollView.addSubview(chipStackView)
        NSLayoutConstraint.activate([
            chipStackView.leadingAnchor.constraint(equalTo: chipScrollView.contentLayoutGuide.leadingAnchor),
            chipStackView.trailingAnchor.constraint(equalTo: chipScrollView.contentLayoutGuide.trailingAnchor),
            chipStackView.topAnchor.constraint(equalTo: chipScrollView.contentLayoutGuide.topAnchor),
            chipStackView.bottomAnchor.constraint(equalTo: chipScrollView.contentLayoutGuide.bottomAnchor),
            chipStackView.heightAnchor.constraint(equalTo: chipScrollView.frameLayoutGuide.heightAnchor)
        ])
    }

    private func configureLabels() {
        fallbackBanner.translatesAutoresizingMaskIntoConstraints = false
        fallbackBanner.numberOfLines = 0
        fallbackBanner.font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .footnote).pointSize)
        fallbackBanner.textColor = .systemOrange
        fallbackBanner.backgroundColor = .systemOrange.withAlphaComponent(0.12)
        fallbackBanner.layer.cornerRadius = 8
        fallbackBanner.accessibilityIdentifier = "explore.fallbackBanner"

        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.numberOfLines = 2
        statusLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        statusLabel.textColor = .secondaryLabel
        statusLabel.accessibilityIdentifier = "explore.status"
    }

    private func configureMap() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.delegate = self
        mapView.layer.cornerRadius = 12
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "Place")
        mapView.accessibilityIdentifier = "explore.map"
    }

    private func configureTable() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 64
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PlaceCell")
        tableView.accessibilityIdentifier = "explore.places"
    }

    private func configureLayout() {
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.accessibilityIdentifier = "explore.loading"

        let root = UIStackView(arrangedSubviews: [
            chipScrollView,
            fallbackBanner,
            statusLabel,
            mapView,
            loadingIndicator,
            tableView
        ])
        root.axis = .vertical
        root.spacing = 8
        root.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(root)

        NSLayoutConstraint.activate([
            root.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            root.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            root.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            root.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            chipScrollView.heightAnchor.constraint(equalToConstant: 48),
            mapView.heightAnchor.constraint(equalToConstant: 260),
            loadingIndicator.heightAnchor.constraint(equalToConstant: 20)
        ])
    }

    private func bindViewModel() {
        viewModel.$selectedCategory
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.render() }
            .store(in: &cancellables)

        viewModel.$places
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.render() }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.render() }
            .store(in: &cancellables)

        viewModel.$isUsingFallback
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.render() }
            .store(in: &cancellables)

        viewModel.$currentLocation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.render() }
            .store(in: &cancellables)

        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                } else {
                    self?.loadingIndicator.stopAnimating()
                }
            }
            .store(in: &cancellables)
    }

    private func render() {
        updateChips()

        fallbackBanner.isHidden = !viewModel.isUsingFallback
        fallbackBanner.text = viewModel.isUsingFallback
            ? "Location unavailable. Showing results near \(LocationFallback.cityName) by default."
            : nil

        if let errorMessage = viewModel.errorMessage {
            statusLabel.text = errorMessage
            statusLabel.textColor = .systemRed
        } else {
            let placeName = viewModel.isUsingFallback ? LocationFallback.cityName : "your location"
            statusLabel.text = "\(viewModel.selectedCategory.title) near \(placeName)"
            statusLabel.textColor = .secondaryLabel
        }

        let annotations = viewModel.places.map { PlaceAnnotation(place: $0) }
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(annotations)

        let center = annotations.first?.coordinate ?? viewModel.currentLocation.coordinate
        let region = MKCoordinateRegion(
            center: center,
            latitudinalMeters: 5_000,
            longitudinalMeters: 5_000
        )
        mapView.setRegion(region, animated: true)
        tableView.reloadData()
    }

    private func updateChips() {
        for button in chipStackView.arrangedSubviews.compactMap({ $0 as? UIButton }) {
            guard PlaceCategory.allCases.indices.contains(button.tag) else { continue }
            let category = PlaceCategory.allCases[button.tag]
            let isSelected = category == viewModel.selectedCategory
            var configuration = button.configuration ?? .plain()
            configuration.background.backgroundColor = isSelected
                ? UIColor.systemTeal.withAlphaComponent(0.22)
                : UIColor.secondarySystemBackground
            configuration.baseForegroundColor = isSelected ? .systemTeal : .label
            button.configuration = configuration
        }
    }

    @objc private func categoryTapped(_ sender: UIButton) {
        guard PlaceCategory.allCases.indices.contains(sender.tag) else { return }
        viewModel.selectCategory(PlaceCategory.allCases[sender.tag])
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? PlaceAnnotation else { return nil }
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: "Place") as? MKMarkerAnnotationView
            ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "Place")
        view.annotation = annotation
        view.canShowCallout = true
        view.markerTintColor = .systemTeal
        return view
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation as? PlaceAnnotation,
              let place = viewModel.places.first(where: { $0.id == annotation.placeID })
        else { return }
        showDetail(for: place)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.places.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath)
        let place = viewModel.places[indexPath.row]
        var configuration = cell.defaultContentConfiguration()
        configuration.text = place.name
        configuration.secondaryText = "\(place.subtitle) • \(DistanceFormatter.string(from: place.distance))"
        cell.contentConfiguration = configuration
        cell.accessoryType = .disclosureIndicator
        cell.accessibilityIdentifier = "explore.place.\(indexPath.row)"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showDetail(for: viewModel.places[indexPath.row])
    }

    private func showDetail(for place: Place) {
        let detail = PlaceDetailViewController(place: place)
        navigationController?.pushViewController(detail, animated: true)
    }
}
