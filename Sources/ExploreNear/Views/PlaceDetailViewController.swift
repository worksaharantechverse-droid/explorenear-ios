import UIKit

final class PlaceDetailViewController: UIViewController {
    private let place: Place

    private let nameLabel = UILabel()
    private let addressLabel = UILabel()
    private let distanceLabel = UILabel()
    private let phoneButton = UIButton(type: .system)
    private let websiteButton = UIButton(type: .system)
    private let directionsButton = UIButton(type: .system)
    private let directionsURLLabel = UILabel()

    init(place: Place) {
        self.place = place
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Place Details"
        view.backgroundColor = .systemBackground
        configureViews()
        configureLayout()
    }

    private var directionsURL: URL {
        var components = URLComponents(string: "maps://")
        components?.queryItems = [
            URLQueryItem(name: "daddr", value: "\(place.coordinate.latitude),\(place.coordinate.longitude)"),
            URLQueryItem(name: "q", value: place.name)
        ]
        return components?.url ?? URL(string: "https://maps.apple.com/")!
    }

    private func configureViews() {
        nameLabel.text = place.name
        nameLabel.font = UIFont.boldSystemFont(ofSize: 22)
        nameLabel.numberOfLines = 0
        nameLabel.accessibilityIdentifier = "detail.name"

        addressLabel.text = place.subtitle
        addressLabel.font = UIFont.preferredFont(forTextStyle: .body)
        addressLabel.numberOfLines = 0
        addressLabel.textColor = .secondaryLabel
        addressLabel.accessibilityIdentifier = "detail.address"

        distanceLabel.text = "Distance: \(DistanceFormatter.string(from: place.distance))"
        distanceLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        distanceLabel.accessibilityIdentifier = "detail.distance"

        phoneButton.setTitle(place.phoneNumber.map { "Call \($0)" } ?? "No phone number", for: .normal)
        phoneButton.isHidden = place.phoneNumber == nil
        phoneButton.contentHorizontalAlignment = .left
        phoneButton.addTarget(self, action: #selector(callPlace), for: .touchUpInside)
        phoneButton.accessibilityIdentifier = "detail.phone"

        websiteButton.setTitle(place.url.map { "Visit \($0.host ?? "website")" } ?? "No website", for: .normal)
        websiteButton.isHidden = place.url == nil
        websiteButton.contentHorizontalAlignment = .left
        websiteButton.addTarget(self, action: #selector(openWebsite), for: .touchUpInside)
        websiteButton.accessibilityIdentifier = "detail.website"

        directionsButton.setTitle("Open directions in Maps", for: .normal)
        directionsButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        directionsButton.addTarget(self, action: #selector(openDirections), for: .touchUpInside)
        directionsButton.accessibilityIdentifier = "detail.directions"

        directionsURLLabel.text = directionsURL.absoluteString
        directionsURLLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        directionsURLLabel.numberOfLines = 0
        directionsURLLabel.textColor = .secondaryLabel
        directionsURLLabel.accessibilityIdentifier = "detail.directionsURL"
    }

    private func configureLayout() {
        let stack = UIStackView(arrangedSubviews: [
            nameLabel,
            addressLabel,
            distanceLabel,
            phoneButton,
            websiteButton,
            directionsButton,
            directionsURLLabel
        ])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
    }

    @objc private func callPlace() {
        guard let phoneNumber = place.phoneNumber else { return }
        let digits = phoneNumber.filter { $0.isNumber }
        guard let url = URL(string: "tel://\(digits)") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    @objc private func openWebsite() {
        guard let url = place.url else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    @objc private func openDirections() {
        UIApplication.shared.open(directionsURL, options: [:], completionHandler: nil)
    }
}
