//
//  MKMapView+Rx.swift
//  Acha
//
//  Created by  sangyeon on 2022/12/08.
//

import Foundation
import RxSwift
import RxCocoa
import MapKit

class RxMKMapViewDelegateProxy: DelegateProxy<MKMapView, MKMapViewDelegate>, DelegateProxyType, MKMapViewDelegate {
    static func registerKnownImplementations() {
        self.register { mapView -> RxMKMapViewDelegateProxy in
            RxMKMapViewDelegateProxy(parentObject: mapView, delegateProxy: self)
        }
    }
    
    static func currentDelegate(for object: MKMapView) -> MKMapViewDelegate? {
        return object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: MKMapViewDelegate?, to object: MKMapView) {
        object.delegate = delegate
    }
}

extension Reactive where Base: MKMapView {
    var delegate: DelegateProxy<MKMapView, MKMapViewDelegate> {
        return RxMKMapViewDelegateProxy.proxy(for: self.base)
    }
    
    var didSelectAnnotation: Observable<MKAnnotation?> {
        return delegate.methodInvoked(#selector(MKMapViewDelegate.mapView(_:didSelect:)))
            .map { parameters in
                let annotaionView = (parameters[1] as? MKAnnotationView) ?? MKAnnotationView()
                return annotaionView.annotation
            }
    }
    
    var didDeselectAnnotation: Observable<MKAnnotation?> {
        return delegate.methodInvoked(#selector(MKMapViewDelegate.mapView(_:didDeselect:)))
            .map { parameters in
                let annotaionView = (parameters[1] as? MKAnnotationView) ?? MKAnnotationView()
                return annotaionView.annotation
            }
    }
    
    var regionDidChange: Observable<MKCoordinateRegion> {
        return delegate.methodInvoked(#selector(MKMapViewDelegate.mapView(_:regionDidChangeAnimated:)))
            .map { parameters in
                let mapView = (parameters[0] as? MKMapView) ?? MKMapView()
                return mapView.region
            }
    }
}
