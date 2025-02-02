//
//  Links.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/21.
//

import Foundation
import SwiftUI

enum Links {
    static let twitterURLString = "https://twitter.com/DeanWThompson"
    static let twitterPoeticURLString = "https://twitter.com/PoeticApp"
    static let poetryDBURLSTring = "https://github.com/thundercomb/poetrydb"
    static let poeticURLString = "https://github.com/thompson-dean/Poetic"
    static let appStoreDeepLink = "itms-apps://apple.com/app/id1614416936"
    static let appStoreWebsiteLink = "https://apps.apple.com/us/app/poetic/id1614416936"
    static let gitHubLink = "https://github.com/thompson-dean"

    static func shareQuote(quote: String, title: String, author: String) {
        let sharedString = """
"\(quote)" A quote from \(title) by \(author), found on Poetic, your favorite classical poetry app.
Available here:  https://apps.apple.com/us/app/poetic/id1614416936
"""
        let activityViewController = UIActivityViewController(activityItems: [sharedString], applicationActivities: nil)

        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        window?.rootViewController?.present(activityViewController, animated: true, completion: nil)

    }

    static func sharePoem(poem: [String], title: String, author: String) {
        let sharedString = """
\(title) by \(author) \n \(poem.joined(separator: "\n")) \n
Found on Poetic, your favorite classical poetry app.
Available here:  https://apps.apple.com/us/app/poetic/id1614416936
"""
        let activityViewController = UIActivityViewController(activityItems: [sharedString], applicationActivities: nil)
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        window?.rootViewController?.present(activityViewController, animated: true, completion: nil)
    }

    static func shareApp() {
        let sharedString = "https://apps.apple.com/us/app/poetic/id1614416936"
        let activityViewController = UIActivityViewController(activityItems: [sharedString], applicationActivities: nil)
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        window?.rootViewController?.present(activityViewController, animated: true, completion: nil)
    }

    static let authorLinksDictionary: [String: String] = [
        "Adam Lindsay Gordon": "https://mypoeticside.com/poets/adam-lindsay-gordon-poems",
        "Alan Seeger": "https://mypoeticside.com/poets/alan-seeger-poems",
        "Alexander Pope": "https://mypoeticside.com/poets/alexander-pope-poems",
        "Algernon Charles Swinburne": "https://mypoeticside.com/poets/algernon-charles-swinburne-poems",
        "Ambrose Bierce": "https://mypoeticside.com/poets/ambrose-bierce-poems",
        "Amy Levy": "https://poets.org/poet/amy-levy",
        "Andrew Marvell": "https://mypoeticside.com/poets/andrew-marvell-poems",
        "Ann Taylor": "https://mypoeticside.com/poets/ann-taylor-poems",
        "Anne Bradstreet": "https://mypoeticside.com/poets/anne-bradstreet-poems",
        "Anne Bronte": "https://mypoeticside.com/poets/anne-bronte-poems",
        "Anne Killigrew": "https://mypoeticside.com/poets/anne-killigrew-poems",
        "Anne Kingsmill Finch": "https://mypoeticside.com/poets/anne-kingsmill-finch-poems",
        "Annie Louisa Walker": "https://mypoeticside.com/poets/annie-louisa-walker-poems",
        "Arthur Hugh Clough": "https://mypoeticside.com/poets/arthur-hugh-clough-poems",
        "Ben Jonson": "https://mypoeticside.com/poets/ben-jonson-poems",
        "Charles Kingsley": "https://mypoeticside.com/poets/charles-kingsley-poems",
        "Charles Sorley": "https://mypoeticside.com/poets/charles-hamilton-sorley-poems",
        "Charlotte Bronte": "https://mypoeticside.com/poets/charlotte-bronte-poems",
        "Charlotte Smith": "https://mypoeticside.com/poets/charlotte-smith-poems",
        "Christina Rossetti": "https://mypoeticside.com/poets/christina-georgina-rossetti-poems",
        "Christopher Marlowe": "https://mypoeticside.com/poets/christopher-marlowe-poems",
        "Christopher Smart": "https://mypoeticside.com/poets/christopher-smart-poems",
        "Coventry Patmore": "https://mypoeticside.com/poets/coventry-patmore-poems",
        "Edgar Allan Poe": "https://mypoeticside.com/poets/edgar-allan-poe-poems",
        "Edmund Spenser": "https://mypoeticside.com/poets/edmund-spenser-poems",
        "Edward Fitzgerald": "https://mypoeticside.com/poets/edward-fitzgerald-poems",
        "Edward Lear": "https://mypoeticside.com/poets/edward-lear-poems",
        "Edward Taylor": "https://mypoeticside.com/poets/edward-taylor-poems",
        "Edward Thomas": "https://mypoeticside.com/poets/phillip-edward-thomas-poems",
        "Eliza Cook": "https://mypoeticside.com/poets/eliza-cook-poems",
        "Elizabeth Barrett Browning": "https://mypoeticside.com/poets/elizabeth-barrett-browning-poems",
        "Emily Bronte": "https://mypoeticside.com/poets/emily-bronte-poems",
        "Emily Dickinson": "https://mypoeticside.com/poets/emily-dickinson-poems",
        "Emma Lazarus": "https://mypoeticside.com/poets/emma-lazarus-poems",
        "Ernest Dowson": "https://mypoeticside.com/poets/ernest-christopher-dowson-poems",
        "Eugene Field": "https://mypoeticside.com/poets/eugene-field-poems",
        "Francis Thompson": "https://mypoeticside.com/poets/francis-thompson-poems",
        "Geoffrey Chaucer": "https://mypoeticside.com/poets/geoffrey-chaucer-poems",
        "George Eliot": "https://mypoeticside.com/poets/george-eliot-poems",
        "George Gordon, Lord Byron": "https://mypoeticside.com/poets/lord-byron-poems",
        "George Herbert": "https://mypoeticside.com/poets/george-herbert-poems",
        "George Meredith": "https://mypoeticside.com/poets/george-meredith-poems",
        "Gerard Manley Hopkins": "https://mypoeticside.com/poets/gerard-manley-hopkins-poems",
        "Helen Hunt Jackson": "https://mypoeticside.com/poets/helen-hunt-jackson-poems",
        "Henry David Thoreau": "https://mypoeticside.com/poets/henry-david-thoreau-poems",
        "Henry Vaughan": "https://mypoeticside.com/poets/henry-vaughan-poems",
        "Henry Wadsworth Longfellow": "https://mypoeticside.com/poets/henry-wadsworth-longfellow-poems",
        "Hugh Henry Brackenridge": "https://mypoeticside.com/poets/hugh-henry-brackenridge-poems",
        "Isaac Watts": "https://mypoeticside.com/poets/isaac-watts-poems",
        "James Henry Leigh Hunt": "https://mypoeticside.com/poets/leigh-hunt-poems",
        "James Thomson": "https://mypoeticside.com/poets/james-thomson-poems",
        "James Whitcomb Riley": "https://mypoeticside.com/poets/james-whitcomb-riley-poems",
        "Jane Austen": "https://mypoeticside.com/poets/jane-austen-poems",
        "Jane Taylor": "https://mypoeticside.com/poets/jane-taylor-poems",
        "John Clare": "https://mypoeticside.com/poets/john-clare-poems",
        "John Donne": "https://mypoeticside.com/poets/john-donne-poems",
        "John Dryden": "https://www.poetryfoundation.org/poets/john-dryden",
        "John Greenleaf Whittier": "https://mypoeticside.com/poets/john-greenleaf-whittier-poems",
        "John Keats": "https://mypoeticside.com/poets/john-keats-poems",
        "John McCrae": "https://mypoeticside.com/poets/john-mccrae-poems",
        "John Milton": "https://mypoeticside.com/poets/john-milton-poems",
        "John Trumbull": "https://mypoeticside.com/poets/john-trumbull-poems",
        "John Wilmot": "https://mypoeticside.com/poets/john-wilmot-poems",
        "Jonathan Swift": "https://mypoeticside.com/poets/jonathan-swift-poems",
        "Joseph Warton": "http://famouspoetsandpoems.com/poets/joseph_warton",
        "Joyce Kilmer": "https://mypoeticside.com/poets/joyce-kilmer-poems",
        "Julia Ward Howe": "https://mypoeticside.com/poets/julia-ward-howe-poems",
        "Jupiter Hammon": "https://www.poetryfoundation.org/poets/jupiter-hammon",
        "Katherine Philips": "https://mypoeticside.com/poets/katherine-philips-poems",
        "Lady Mary Chudleigh": "https://mypoeticside.com/poets/mary-chudleigh-poems",
        "Lewis Carroll": "https://mypoeticside.com/poets/lewis-carroll-poems",
        "Lord Alfred Tennyson": "https://mypoeticside.com/poets/alfred-lord-tennyson-poems",
        "Louisa May Alcott": "https://mypoeticside.com/poets/louisa-may-alcott-poems",
        "Major Henry Livingston, Jr.": "https://www.poetryfoundation.org/poets/henry-livingston",
        "Mark Twain": "https://mypoeticside.com/poets/mark-twain-poems",
        "Mary Elizabeth Coleridge": "https://mypoeticside.com/poets/mary-elizabeth-coleridge-poems",
        "Matthew Arnold": "https://mypoeticside.com/poets/matthew-arnold-poems",
        "Matthew Prior": "https://mypoeticside.com/poets/matthew-prior-poems",
        "Michael Drayton": "https://mypoeticside.com/poets/michael-drayton-poems",
        "Oliver Goldsmith": "https://mypoeticside.com/poets/oliver-goldsmith-poems",
        "Oliver Wendell Holmes": "https://mypoeticside.com/poets/oliver-wendell-holmes-poems",
        "Oscar Wilde": "https://mypoeticside.com/poets/oscar-wilde-poems",
        "Paul Laurence Dunbar": "https://mypoeticside.com/poets/paul-laurence-dunbar-poems",
        "Percy Bysshe Shelley": "https://mypoeticside.com/poets/percy-bysshe-shelley-poems",
        "Philip Freneau": "https://mypoeticside.com/poets/philip-morin-freneau-poems",
        "Phillis Wheatley": "https://mypoeticside.com/poets/phillis-wheatley-poems",
        "Ralph Waldo Emerson": "https://mypoeticside.com/poets/ralph-waldo-emerson-poems",
        "Richard Crashaw": "https://mypoeticside.com/poets/richard-crashaw-poems",
        "Richard Lovelace": "https://mypoeticside.com/poets/richard-lovelace-poems",
        "Robert Browning": "https://mypoeticside.com/poets/robert-browning-poems",
        "Robert Burns": "https://mypoeticside.com/poets/robert-burns-poems",
        "Robert Herrick": "https://mypoeticside.com/poets/robert-herrick-poems",
        "Robert Louis Stevenson": "https://mypoeticside.com/poets/robert-louis-stevenson-poems",
        "Robert Southey": "https://mypoeticside.com/poets/robert-southey-poems",
        "Robinson": "https://mypoeticside.com/poets/mary-darby-robinson-poems",
        "Rupert Brooke": "https://mypoeticside.com/poets/rupert-brooke-poems",
        "Samuel Coleridge": "https://mypoeticside.com/poets/samuel-taylor-coleridge-poems",
        "Samuel Johnson": "https://mypoeticside.com/poets/samuel-johnson-poems",
        "Sarah Flower Adams": "https://mypoeticside.com/poets/sarah-flower-adams-poems",
        "Sidney Lanier": "https://mypoeticside.com/poets/sidney-lanier-poems",
        "Sir John Suckling": "https://mypoeticside.com/poets/sir-john-suckling-poems",
        "Sir Philip Sidney": "https://mypoeticside.com/poets/sir-philip-sidney-poems",
        "Sir Thomas Wyatt": "https://mypoeticside.com/poets/sir-thomas-wyatt-poems",
        "Sir Walter Raleigh": "https://mypoeticside.com/poets/sir-walter-raleigh-poems",
        "Sir Walter Scott": "https://mypoeticside.com/poets/sir-walter-scott-poems",
        "Stephen Crane": "https://mypoeticside.com/poets/stephen-crane-poems",
        "Thomas Campbell": "https://mypoeticside.com/poets/thomas-campbell-poems",
        "Thomas Chatterton": "https://mypoeticside.com/poets/thomas-chatterton-poems",
        "Thomas Flatman": "https://allpoetry.com/Thomas-Flatman",
        "Thomas Gray": "https://mypoeticside.com/poets/thomas-gray-poems",
        "Thomas Hood": "https://mypoeticside.com/poets/thomas-hood-poems",
        "Thomas Moore": "https://mypoeticside.com/poets/thomas-moore-poems",
        "Thomas Warton": "https://mypoeticside.com/poets/thomas-warton-poems",
        "Walt Whitman": "https://mypoeticside.com/poets/walt-whitman-poems",
        "Walter Savage Landor": "https://mypoeticside.com/poets/walter-savage-landor-poems",
        "Wilfred Owen": "https://mypoeticside.com/poets/wilfred-owen-poems",
        "William Allingham": "https://mypoeticside.com/poets/william-allingham-poems",
        "William Barnes": "https://mypoeticside.com/poets/william-barnes-poems",
        "William Blake": "https://mypoeticside.com/poets/william-blake-poems",
        "William Browne": "http://famouspoetsandpoems.com/poets/william_browne",
        "William Cowper": "https://mypoeticside.com/poets/william-cowper-poems",
        "William Cullen Bryant": "https://mypoeticside.com/poets/william-cullen-bryant-poems",
        "William Ernest Henley": "https://mypoeticside.com/poets/william-ernest-henley-poems",
        "William Lisle Bowles": "https://mypoeticside.com/poets/william-lisle-bowles-poems",
        "William Morris": "https://mypoeticside.com/poets/william-morris-poems",
        "William Shakespeare": "https://mypoeticside.com/poets/william-shakespeare-poems",
        "William Topaz McGonagall": "https://mypoeticside.com/poets/william-topaz-mcgonagall-poems",
        "William Vaughn Moody": "https://mypoeticside.com/poets/william-vaughn-moody-poems",
        "William Wordsworth": "https://mypoeticside.com/poets/william-wordsworth-poems"
    ]
}
